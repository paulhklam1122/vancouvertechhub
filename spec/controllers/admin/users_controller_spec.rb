require 'rails_helper'
require 'pry'

RSpec.describe Admin::UsersController, type: :controller do
  let (:admin_user) { FactoryGirl.create(:admin) }
  let (:user) { FactoryGirl.create(:user) }
  let (:organization) { FactoryGirl.create(:organization) }
  describe "#new" do
    context "as anon user" do
      it "redirects to root_path" do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    context "as an admin" do
      before { login(admin_user) }
      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end

      it "assigns the user instance variable" do
        get :new
        expect(assigns(:user)).to be_a_new(User)
      end
    end
  end

  describe "#create" do
    context "as anon user" do
      it "redirects to root_path" do
        post :create, user: FactoryGirl.attributes_for(:user)
        expect(response).to redirect_to(root_path)
      end
    end
    context "with valid user attribute" do
      before { login(admin_user) }
      def valid_request
        post :create, user: FactoryGirl.attributes_for(:user)
      end

      it "creates a record in the database" do
          count_before = User.count
          valid_request
          count_after = User.count
          expect(count_after).to eq(count_before + 1)
      end

      # monkey-patched test mailer to call deliver_now
      # in spec/support/message_delivery.rb
      it "sends an account verification e-mail" do
        expect { valid_request }.to change{ActionMailer::Base.deliveries.count}.by(1)
      end

      it "renders the account verificaitons create page" do
        valid_request
        expect(response).to render_template("users/account_verifications/create")
      end

      it "sets the session user_id with the created user" do
        valid_request
        expect(session[:user_id]).to eq(User.last.id)
      end
    end

    context "with invalid user attribute" do
      before { login(admin_user) }
      def invalid_request
        post :create, user: FactoryGirl.attributes_for(:user).merge({first_name: nil})
      end

      it "doesn't add a record to the database" do
        count_before = User.count
        invalid_request
        count_after = User.count
        expect(count_after).to eq(count_before)
      end

      it "renders the new template" do
        invalid_request
        expect(response).to render_template(:new)
      end
    end

  end


  describe "#edit" do
    render_views
    describe "as a mortal" do
    before { login(user) }
      it "redirects to root_path" do
        get :edit, id: user.id
        expect(response).to redirect_to(root_path)
      end
    end
    describe "as an admin" do
    before { login(admin_user) }
      it "shows the option to make the user an admin" do
        get :edit, id: user.id
        expect(response.body).to include("Admin")
      end
    end
  end

  describe "#update" do

    describe "as a mortal" do
      before { login(user) }
      it "redirects to root_path" do
        get :edit, id: user.id
        expect(response).to redirect_to(root_path)
      end
    end
    describe "as administrators" do
      before { login(admin_user) }
      it "can make more administrators" do
        patch :update, id: user.id, user: {admin: true}
        expect(user.reload.admin).to eq(true)
      end
      it "can add organizations to users" do
        patch :update, id: user.id, user: {organization_id: organization.id}
        expect(user.reload.organization).to eq(organization)
      end
    end
  end
end
