require 'spec_helper'

describe UsersController do

  render_views

  before(:each) do
    @test_user_attr = {
        :email => 'testy@example.com',
        :password => 'password'
    }
    @test_user = User.create!(@test_user_attr)
  end

  describe 'Get show' do

    describe 'non-logged-in user' do
      it 'should redirect to the sign-in page' do
        get :show, params: {id: @test_user.id}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'logged-in user' do

      describe 'trying to view wrong account' do

        before(:each) do
          sign_in @test_user
          @test_user2_attr = {
              :email => 'testy2@example.com',
              :password => 'password'
          }
          @test_user2 = User.create!(@test_user2_attr)
        end

        it 'should redirect to the home page' do
          get :show, params: {id: @test_user2.id }
          expect(response).to redirect_to(root_path)
        end

      end

      describe 'viewing correct account' do

        before(:each) do
          sign_in @test_user
        end

        it 'should show the user#show page' do
          get :show, params: {id: @test_user.id}
          expect(response).to be_success
          expect(response.body).to have_selector('#user_account_links_list')
        end

      end

    end

  end

end
