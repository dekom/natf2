require File.dirname(__FILE__) + '/../test_helper'
require 'topics_controller'

# Re-raise errors caught by the controller.
class TopicsController; def rescue_action(e) raise e end; end

class TopicsControllerTest < Test::Unit::TestCase
  all_fixtures

  def setup
    @controller = TopicsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:topics)
  end

  def test_should_create_topic
    login_as :trevor
    old_topic_count = Topic.count
    old_post_count = Post.count
    post :create, :topic => { :title => "test", :body => "this is a test", :forum_id => "1" }  
    assert assigns(:topic)
    assert assigns(:post)
    assert_equal old_topic_count+1, Topic.count
    assert_equal old_post_count+1, Post.count
    assert_redirected_to topic_path(assigns(:topic))
  end
  
  def test_must_be_logged_in_to_post_topic
    old_count = Topic.count
    post :create, :topic => { :title => "test", :body => "this is a test" }  
    assert_redirected_to login_path
  end

  def test_should_fail_to_get_new_if_not_logged_in
    get :new
    assert_redirected_to login_path
  end

  def test_should_get_new_if_logged_in
    login_as :trevor
    get :new
    assert_response :success
  end
  
  def test_should_show_topic
    get :show, :id => 1
    assert_response :success
  end

  def test_should_not_show_private_topic_unless_logged_in
    get :show, :id => 2
    assert_redirected_to login_path
  end
  
  def test_should_show_private_topic_if_logged_in
    login_as :trevor
    get :show, :id => 2
    assert_response :success
  end

  def test_should_fail_to_get_edit_unless_user_created_topic
    get :edit, :id => 1
    assert_redirected_to login_path
  end
  
  def test_should_get_edit_if_user_created_topic
    login_as :trevor
    get :edit, :id => 1
    assert_response :success
  end
 
  def test_should_fail_to_update_topic_if_not_authorized
    put :update, :id => 1, :topic => { :title => "bogus!"}
    assert_redirected_to login_path
    assert_equal "Testing", topics(:Testing).title
  end
  
  def test_should_update_topic_if_authorized
    login_as :trevor
    put :update, :id => 1, :topic => { :title => "ok!", :body => "ok!" }
    assert_redirected_to topic_path(assigns(:topic))
    assert_equal "ok!", topics(:Testing).title
  end
  
  def test_should_fail_to_update_topic_if_wrong_user
    login_as :Timothy
    put :update, :id => 1, :topic => { :title => "bogus!" }
    assert_redirected_to topic_path(topics(:Testing))
    assert_equal "Testing", topics(:Testing).title
  end
  
  def test_should_update_topic_if_admin
    login_as :Administrator
    put :update, :id => 1, :topic => { :title => "admin!" }
    assert_redirected_to topic_path(assigns(:topic))
    assert_equal "admin!", topics(:Testing).title
  end

  def test_should_fail_to_destroy_topic_if_not_authorized
    old_count = Topic.count
    delete :destroy, :id => 1
    assert_equal old_count, Topic.count
    assert_redirected_to login_path
  end
  
  def test_should_destroy_topic_if_user_that_created_topic
    login_as :trevor
    old_count = Topic.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Topic.count
    assert_redirected_to topics_path
  end
  
  def test_should_fail_to_destroy_topic_if_wrong_user
    login_as :Timothy
    old_count = Topic.count
    delete :destroy, :id => 1
    assert_equal old_count, Topic.count
    assert_redirected_to topic_path(topics(:Testing))
  end
  
  def test_should_destroy_topic_if_admin
    login_as :Administrator
    old_count = Topic.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Topic.count
    assert_redirected_to topics_path
  end
  
  def test_should_redirect_to_topic_with_viewtopic_php_style_url
    get :unknown_request, :path => "viewtopic.php", :pid => "1"
    assert_redirected_to topic_path(:id => "1")
  end
  
  def test_should_redirect_to_topic_with_viewtopic_php_style_url_second_version
  end
  
  def test_should_redirect_to_home_path_if_viewtopic_id_not_found
    # get :unknown_request, :path => "viewtopic.php", :id => "23823"
    # assert_redirected_to topic_path(:id => "23823")
    # assert_redirected_to home_path
  end
  
  def test_should_fail_to_find_topic_with_viewtopic_php_url_if_private_and_not_logged_in
    # get :unknown_request, :path => "viewtopic.php", :id => "2"
    # assert_redirected_to topic_path(:id => "2")
  end
  
  def test_should_find_topic_with_viewtopic_php_url_if_private_and_logged_in
    # login_as :trevor
    # get :unknown_request, :path => "viewtopic.php", :id => "2"
    # assert_redirected_to topic_path(:id => "2")
  end
  
  def test_should_set_last_post_info_in_forum_and_topic_on_new_topic
  end
  
  def test_should_set_last_post_info_in_forum_and_topic_on_new_post_in_existing_topic
  end
  
  def test_should_set_last_post_info_in_forum_and_topic_if_most_recent_post_is_deleted
  end
  
  def test_should_show_topic_as_new
  end
  
  def test_should_not_show_topic_as_new
  end
  
  def test_should_redirect_to_newest_post_with_show_new_action
    login_as :post_test
    get :show_new, :id => 1
    # assert_redirected_to topic_path(:id => "1", :anchor => 'p' + posts(:one2).id.to_s)
  end
  
  def test_should_redirect_to_last_post_if_no_new_posts_with_show_new_action
    login_as :trevor
    get :show_new, :id => 1
    # assert_redirected_to topic_path(:id => "1", :anchor => 'p' + posts(:one3).id.to_s) 
  end
  
  def test_should_redirect_to_top_of_page_for_topic_with_no_anchor_if_first_post_in_thread
    login_as :trevor
    get :show_new, :id => 2
    assert_redirected_to topic_path(:id => "2") 
  end
  
  def test_should_send_banned_user_to_logout
    login_as :banned
    get :index
    assert_redirected_to logout_path
  end
  
  def test_should_redirect_to_same_path_when_logging_in_with_cookie
    # log in
    # delete cookie
    # use show_new action, which should use the cookie to log in and redirect to the requested url
    # get :show_new, :id => 1
    # assert_redirected_to topic_path(:id => "1", :anchor => 'p' + posts(:one3).id.to_s)
  end
  
end
