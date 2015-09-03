require 'spec_helper'

describe FoldersController do

  render_views

  before(:each) do
    @test_user_attr = {
        :email => "testy@example.com",
        :password => "password"
    }
    @test_user = User.create!(@test_user_attr)
  end

  describe "GET index" do

    describe "non-logged in user" do

      it "should link to the bookmarks folder" do
        get :index
        expect(response.body).to have_selector("a[href='/bookmarks']")
      end

      it "should not show any folders" do
        get :index
        expect(@folders).to be_nil
      end

    end

    describe "logged-in user" do

      before(:each) do
        sign_in @test_user
      end

      describe "user has no folders yet" do

        it "should not show any folders" do
          get :index
          expect(@test_user.folders).to be_empty
          expect(@folders).to be_nil
        end

      end

      describe "user has folders" do

        before(:each) do
          @test_folder_attr = {:title => "Test Folder Title",:visibility => 'private'}
          @test_user.folders.create!(@test_folder_attr)
        end

        it "should show the user's folders" do
          get :index
          expect(response.body).to have_selector("ul[id='user_folder_list']")
        end

      end

    end

  end

  describe "DELETE destroy" do

    before(:each) do
      @test_folder_attr = {:title => "Test Folder Title",:visibility => 'private'}
      @test_user.folders.create!(@test_folder_attr)
    end

    describe "non-logged in user" do

      it "should redirect to the login page" do
        delete :destroy, :id => @test_user.folders.first.id
        expect(response).to be_redirect
      end

    end

    describe "logged-in user" do

      before(:each) do
        sign_in @test_user
      end

      it "should delete the folder" do
        expect {
          delete :destroy, :id => @test_user.folders.first.id
        }.to change(Bpluser::Folder, :count).by(-1)
      end

      it "should redirect to the folders page" do
        delete :destroy, :id => @test_user.folders.first.id
        expect(response).to redirect_to(:controller => 'folders', :action => 'index')
      end

    end

  end

  describe "GET new" do

    before(:each) do
      sign_in @test_user
    end

    it "should return http success" do
      get :new
      expect(response).to be_success
    end

    it "should display the form" do
      get :new
      expect(response.body).to have_selector("form[id='edit_folder_form']")
    end

  end

  describe "GET show" do

    before(:each) do
      @test_folder_attr = {:title => "Test Folder Title",:visibility => 'private'}
      @folder = @test_user.folders.create!(@test_folder_attr)
    end

    describe "non-logged in user" do

      describe 'private folder' do

        it "should redirect to the login page" do
          get :show, :id => @folder.id
          expect(response).to be_redirect
        end

      end

      describe 'public folder' do

        before(:each) do
          @public_test_folder_attr = {:title => "Public Test Folder Title",:visibility => 'public'}
          @public_folder = @test_user.folders.create!(@public_test_folder_attr)
        end

        it "should show the folder" do
          get :show, :id => @public_folder.id
          expect(response.body).to have_selector("h2", :text => @public_folder.title)
        end

      end

    end

    describe "logged-in user" do

      before(:each) do
        sign_in @test_user
      end

      it "should show the folder title" do
        get :show, :id => @folder.id
        expect(response.body).to have_selector("h2", :text => @folder.title)
      end

      describe "user has folder with items" do

        before(:each) do
          @test_folder_item = @folder.folder_items.create!(:document_id => 'bpl-dev:h702q6403')
        end

        it "should show a link to the folder item" do
          get :show, :id => @folder.id
          expect(response.body).to have_selector("a[href='/search/" + @test_folder_item.document_id + "']")
        end

      end

    end

    describe "wrong user" do

      before(:each) do
        sign_in @test_user
        @test_folder_attr = {:title => "Test Folder Title",:visibility => 'private'}
        @folder = @test_user.folders.create!(@test_folder_attr)
        sign_out @test_user
        @other_user_attr = {
            :email => "testy@other.com",
            :password => "password"
        }
        @other_user = User.create!(@other_user_attr)
        sign_in @other_user
      end

      it "should not allow access to another user's folder" do
        get :show, :id => @folder.id
        expect(response).to redirect_to(root_path)
      end

    end

  end

  describe "POST create" do

    describe "non-logged-in user" do

      #it "should deny access to create" do
      #  post :create
      #  TODO: below doesn't work due to ?referer=%2Ffolders suffix on end of URL.
      #  not sure how to test for this.
      #  expect(response).to redirect_to(:controller => 'devise/sessions', :action => 'new' )
      #end

    end

    describe "logged-in user" do

      before(:each) do
        sign_in @test_user
      end

      describe "failure" do

        it "should not create a folder" do
          expect {
            post :create, :folder => {:title => ""}
          }.not_to change(Bpluser::Folder, :count)
        end

        it "should re-render the create page" do
          post :create, :folder => {:title => ""}
          expect(response).to render_template('folders/new')
        end

      end

      describe "success" do

        it "should create a folder" do
          expect do
            post :create, :folder => {:title => "Whatever, man",:visibility => 'private'}
          end.to change(Bpluser::Folder, :count).by(1)
        end

        it "should redirect to the folders page" do
          post :create, :folder => {:title => "Whatever, man",:visibility => 'private'}
          expect(response).to redirect_to(:controller => 'folders', :action => 'index')
        end

      end


    end

  end

  describe "GET edit" do

    before(:each) do
      @test_folder_attr = {:title => "Test Folder Title",:visibility => 'private'}
      @folder = @test_user.folders.create!(@test_folder_attr)
    end

    describe "non-logged-in user" do

      #it "should deny access to edit" do
      #  get :edit, :id => @folder.id
      #  TODO: below doesn't work due to ?referer=%2Ffolders suffix on end of URL. not sure how to test for this.
      #  expect(response).to redirect_to(:controller => 'devise/sessions', :action => 'new' )
      #end

    end

    describe "logged-in user" do

      before(:each) do
        sign_in @test_user
      end

      it "should show the edit form with the correct title value" do
        get :edit, :id => @folder.id
        expect(response.body).to have_field("folder_title", :with => @folder.title)
      end

    end

  end

  describe "PUT update" do

    before(:each) do
      @test_folder_attr = {:title => "Test Folder Title",:visibility => 'private'}
      @folder = @test_user.folders.create!(@test_folder_attr)
    end

    describe "non-logged-in user" do

      #it "should deny access to create" do
      #put :update, :id => @folder.id
      # TODO: below doesn't work due to ?referer=%2Ffolders suffix on end of URL. not sure how to test for this.
      #expect(response).to redirect_to(:controller => 'devise/sessions', :action => 'new' )
      #end

    end

    describe "logged-in user" do

      before(:each) do
        sign_in @test_user
      end

      describe "failure" do

        it "should not update the folder" do
          put :update, :id => @folder.id, :folder => {:title => ""}
          @folder.reload
          expect(@folder.title).not_to eq("")
        end

        it "should re-render the edit form" do
          put :update, :id => @folder.id, :folder => {:title => ""}
          expect(response).to render_template('folders/edit')
        end

      end

      describe "success" do

        it "should update the folder" do
          put :update, :id => @folder.id, :folder => {:title => "New Folder Title"}
          @folder.reload
          expect(@folder.title).to eq("New Folder Title")
        end

        it "should redirect to the folders show page" do
          put :update, :id => @folder.id, :folder => {:title => "New Folder Title"}
          expect(response).to redirect_to(:controller => 'folders', :action => 'show')
        end

      end

    end

  end

  describe 'GET public_list' do

    before(:each) do
      @test_folder_attr = {:title => "Test Folder Title",:visibility => 'public'}
      @folder = @test_user.folders.create!(@test_folder_attr)
      @folder.folder_items.create!(:document_id => 'bpl-test:gq67js019')
    end

    it 'should show the public list' do
      get :public_list
      expect(response).to be_success
      expect(response.body).to have_css('body.blacklight-folders-public_list')
    end

    it 'should show the public folder in the list' do
      get :public_list
      expect(response.body).to have_selector('a', :text => @folder.title)
    end

  end

end
