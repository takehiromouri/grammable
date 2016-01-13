require 'rails_helper'

RSpec.describe PostsController, type: :controller do
	describe "posts#index action" do
		it "should succesfully show the page" do
			get	:index
			expect(response).to have_http_status(:success)
		end
	end

	describe "posts#new action" do
		it "should require users to be logged in" do
			get :new
			expect(response).to redirect_to new_user_session_path
		end
		it "should successfully show the new form" do
			user = FactoryGirl.create(:user)
			sign_in user
			get :new
			expect(response).to have_http_status(:success)
		end
	end

	describe "posts#create action" do
		it "should require users to be logged in" do
			post :create, post: {message: "Hello!"}
			expect(response).to redirect_to new_user_session_path
		end
		it "should successfully create a new post in our database" do
			user = FactoryGirl.create(:user)
			sign_in user
			post :create, post: {message: "Hello!"}
			expect(response).to redirect_to root_path
			post = Post.last
			expect(post.message).to eq("Hello!")
			expect(post.user).to eq(user)
		end
		it "should properly deal with validation errors" do
			user = FactoryGirl.create(:user)
			sign_in user
			post :create, post: {message: ""}
			expect(response).to have_http_status(:unprocessable_entity)
			expect(Post.count).to eq 0
		end
	end

	describe "posts#show action" do
		it "should successfully show the page if the post if found" do
			post = FactoryGirl.create(:post)
			get :show, id: post.id
			expect(response).to have_http_status(:success)
		end
		it "should return a 404 error if the post is not found" do
			get :show, id: 'TACOCAT'
			expect(response).to have_http_status(:not_found)
		end
	end

end
