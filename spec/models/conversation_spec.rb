require 'spec_helper'

describe Conversation do
  context "General Model Methods" do
    before do
      @conversation = create(:conversation)
    end

    it "should be valid" do
      @conversation.valid?.should be_true
    end

    describe "associations" do
      it "should know about any related Comments" do
        @conversation.comments.should == []
      end
      it "should know its participant count" do
        create(:comment, conversation: @conversation)
        @conversation.participant_count.should eq 1
      end
    end

    describe "validations" do
      it "should require a Forum" do
        @conversation.forum = nil
        @conversation.valid?.should be_false
      end
    end

    describe "accessible attributes" do
      it "should allow :title" do
        new_title = "Something Else"
        @conversation.update_attributes({:title => new_title})
        @conversation.title.should == new_title
      end

      it "should allow :forum_id" do
        forum = create(:forum)
        @conversation.update_attributes({:forum_id => forum.id})
        @conversation.forum.should == forum
      end
    end
    it "should know about its original author" do
      u1 = create(:user)
      u2 = create(:user)
      conversation = create(:conversation, :creator => u1)
      c1 = create(:comment, :user => u1, conversation: conversation)
      c2 = create(:comment, :user => u2, conversation: conversation)
      conversation.original_author.should == u1
    end

    it "original author should be a User" do
      @conversation.original_author.should be_a(User)
    end
  end
  context 'sorting' do
    before do
      start_time = Time.local(2012, 01, 01, 8, 0)
      Timecop.freeze(start_time)
      @c1 = create(:conversation)
      later = Time.local(2012, 01, 01, 8, 5) # 8:05 Jan 1
      Timecop.freeze(later)
      @c2 = create(:conversation)
    end

    it "should order the conversations by their updated_at" do
      Conversation.all.should eq [@c2, @c1]
    end

    it "creating a new post will change the order" do
      even_later = Time.local(2012, 01, 01, 9, 0)
      Timecop.freeze(even_later)
      create(:comment, conversation: @c1)
      Conversation.all.should eq [@c1, @c2]
    end
    after do
      Timecop.return
    end
  end

  context 'comments counter' do
    before do
      @conversation = create(:conversation)
    end

    it 'counter cache should increment when a comment is added' do
      original_comments_count = @conversation.comments_count
      create(:comment, conversation: @conversation)
      Conversation.find(@conversation.id).comments_count.should eq (original_comments_count + 1)
    end

    it 'counter cache should decrement when a comment is destroyed' do
      Conversation.find(@conversation.id).comments.destroy_all
      Conversation.find(@conversation.id).comments_count.should eq 0
    end
  end
end
