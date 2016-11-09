require 'test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  test "should get vote" do
    get :vote
    assert_response :success
  end

end
