require 'spec_helper'

describe ConversationsController do
  before do
    @current_user = create(:user)
    sign_in @current_user
  end

  describe "GET 'new'" do
    it "returns http success" do
      Forum.stub(:find).and_return(create(:forum))
      get 'new', :forum_id => 1
      response.should be_success
    end
  end

end
