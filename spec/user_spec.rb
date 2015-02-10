require 'spec_helper'

describe "User API" do

  include_context "configuration"

  describe "Session" do
    it "logs the user on " do
      VCR.use_cassette("user_login_success") do
        logged_on_user=client.login(user_details[:email], user_details[:password])
        expect(logged_on_user.session[:session_id]).not_to be nil
        expect(client.current_user).not_to be nil
      end
    end

    it "not logs the user on " do
      VCR.use_cassette("user_login_failure") do
        expect { client.login(user_details[:email], "foobar")}.to raise_error
      end
    end

    it "logs the user out " do
      VCR.use_cassette("user_logout_success") do
        client.login(user_details[:email], user_details[:password])
        expect(client.current_user.logout).to be true
      end
    end
  end

  describe "Receipts" do
    it "returns the list of receipts for the currently logged on user" do
      VCR.use_cassette("user_receipts_list_success") do
          client.login(user_details[:email], user_details[:password])
          client.current_user.receipts
      end
    end
  end
end
