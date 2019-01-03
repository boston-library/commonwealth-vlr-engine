require 'rails_helper'

describe FolderItemsController do

  #having trouble with POST create should create a new folder item using ajax when views rendered
  #render_views

  before(:each) do
    @test_user_attr = {
        :email => "testy@example.com",
        :password => "password"
    }
    @test_user = User.create!(@test_user_attr)
    sign_in @test_user
    @test_folder_attr = {:title => "Test Folder Title", :visibility => 'private'}
    @folder = @test_user.folders.create!(@test_folder_attr)
  end


  describe "POST create" do

    describe "success" do

      it "should create a new folder item" do
        expect {
          @request.env['HTTP_REFERER'] = '/folder_items/new'
          post :create, params: {id:  "bpl-dev:h702q6403", folder_id: @folder.id }
          expect(response).to be_redirect
          expect(@test_user.existing_folder_item_for("bpl-dev:h702q6403")).not_to be_nil
        }.to change(Bpluser::FolderItem, :count).by(1)
      end

      it "should create a new folder item using ajax" do
        expect {
          post :create, xhr: true, params: {id: "bpl-dev:g445cd14k", folder_id: @folder.id }
          expect(response).to be_successful
          expect(@test_user.existing_folder_item_for("bpl-dev:g445cd14k")).not_to be_nil
        }.to change(Bpluser::FolderItem, :count).by(1)
      end

    end

  end

  describe "DELETE destroy" do

    describe "success" do

      before(:each) do
        @folder.folder_items.create!(:document_id => "bpl-dev:g445cd14k")
      end

      it "should delete a folder item" do
        expect {
          @request.env['HTTP_REFERER'] = '/folder_items'
          delete :destroy, params: {id: "bpl-dev:g445cd14k"}
          expect(response).to be_redirect
        }.to change(Bpluser::FolderItem, :count).by(-1)
      end

      it "should delete a folder item using ajax" do
        expect {
          delete :destroy, xhr: true ,params: {id: "bpl-dev:g445cd14k" }
          expect(response).to be_successful
        }.to change(Bpluser::FolderItem, :count).by(-1)
      end

    end

  end

  describe "DELETE clear" do

    describe "success" do

      before(:each) do
        @folder.folder_items.create!(:document_id => "bpl-dev:g445cd14k")
      end

      it "should clear the folder's folder items" do
        delete :clear, params: { id: @folder.id }
        expect(@folder.folder_items.count).to eq(0)
      end

    end

  end


end
