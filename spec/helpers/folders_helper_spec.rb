require 'rails_helper'

describe FoldersHelper do

  before(:each) do
    @test_user = User.create!({:email => 'testy@test.com', :password => 'password'})
    @folder = @test_user.folders.create!({:title => 'Test Folder Title',:visibility => 'private'})
  end

  describe '#folder_belongs_to_user' do

    describe 'correct user' do
      before { allow(helper).to receive(:current_or_guest_user).and_return(@test_user) }
      it 'should return true if the folder belongs to the current_or_guest_user' do
        expect(helper.folder_belongs_to_user).to be_truthy
      end
    end

    describe 'incorrect user' do
      before {
        @wrong_user = User.create!({:email => 'testy2@test2.com', :password => 'password'})
        allow(helper).to receive(:current_or_guest_user).and_return(@wrong_user)
      }
      it 'should return false if the folder does not belong to the current_or_guest_user' do
        expect(helper.folder_belongs_to_user).to be_falsey
      end
    end

  end

end