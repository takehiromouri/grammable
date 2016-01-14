require 'rails_helper'

RSpec.describe PostsController, type: :controller do

	describe "posts#destroy" do
		it "shouldn't allow users who didn't create the post to destroy it" do
    	p = FactoryGirl.create(:post)
		  user = FactoryGirl.create(:user)
		  sign_in user
		  delete :destroy, :id => p.id
		  expect(response).to have_http_status(:forbidden)
  	end

		it "shouldn't let unauthenticated users destroy a post" do
      p = FactoryGirl.create(:post)
      delete :destroy, :id => p.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow a user to destroy posts" do
      p = FactoryGirl.create(:post)
      sign_in p.user
      delete :destroy, id: p.id
      expect(response).to redirect_to root_path
      p = Post.find_by_id(p.id)
      expect(p).to eq nil
    end

    it "should return a 404 message if we cannot find a post with the id that is specified" do
    	u = FactoryGirl.create(:user)
  		sign_in u
      delete :destroy, id: 'SPACEDUCK'
      expect(response).to have_http_status(:not_found)
    end
  end

	describe "posts#update" do
		it "shouldn't let users who didn't create the post update it" do
    	p = FactoryGirl.create(:post)
		  user = FactoryGirl.create(:user)
		  sign_in user
		  patch :update, :id => p.id, :post => {:message => 'wahoo'}
		  expect(response).to have_http_status(:forbidden)
  	end

		it "shouldn't let unauthenticated users create a post" do
      p = FactoryGirl.create(:post)
      patch :update, :id => p.id, :post => { :message => "Hello" }
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to successfully update posts" do
		  p = FactoryGirl.create(:post, :message => "Initial Value")
		  sign_in p.user
		  patch :update, :id => p.id, :post => { :message => 'Changed' }
		  expect(response).to redirect_to root_path
		  p.reload
		  expect(p.message).to eq "Changed"
		end

    it "should have http 404 error if the post cannot be found" do
    	u = FactoryGirl.create(:user)
  		sign_in u
		  patch :update, :id => "YOLOSWAG", :post => {:message => 'Changed'}
		  expect(response).to have_http_status(:not_found)
		end


    it "should render the edit form with an http status of unprocessable_entity" do
		  p = FactoryGirl.create(:post, :message => "Initial Value")
		  sign_in p.user
		  patch :update, :id => p.id, :post => { :message => '' }
		  expect(response).to have_http_status(:unprocessable_entity)
		  p.reload
		  expect(p.message).to eq "Initial Value"
		end
  end

	describe "posts#edit" do
		it "shouldn't let a user who did not create the post edit a post" do
    	p = FactoryGirl.create(:post)
		  user = FactoryGirl.create(:user)
		  sign_in user
		  get :edit, :id => p.id
		  expect(response).to have_http_status(:forbidden)
  	end

		it "shouldn't let unauthenticated users edit a post" do
      p = FactoryGirl.create(:post)
      get :edit, :id => p.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the post is found" do
      post = FactoryGirl.create(:post)
      sign_in post.user
      get :edit, id: post.id
      expect(response).to have_http_status(:success)
    end
    
    it "should return a 404 error message if the post is not found" do
    	u = FactoryGirl.create(:user)
  		sign_in u
      get :edit, id: 'LOL'
      expect(response).to have_http_status(:not_found)
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



end
