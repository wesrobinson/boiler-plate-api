require 'spec_helper'

describe UsersController do

  let(:json) { JSON.parse(last_response.body) }

  context "when creating a user" do
    before(:each) do
      @user_params = {
        email: Faker::Internet.email,
        password: Faker::Internet.password(9),
        full_name: Faker::Name.name
      }
    end

    it "should return the user object after creation" do
      post '/api/users', @user_params
      expect(json['email']).to eq(@user_params[:email])
    end

    it "should assign the channel_id" do
      channel_id = 'bc775f32-7a7c-4ee2-ac7c-a5e8bc97eb4a'
      post '/api/users', @user_params.merge(channel_id: channel_id)
      expect(json['channel_ids']).to eq([channel_id])
    end

    it "should return a record invalid error if email has already been taken" do
      existing_user = create(:user, email: @user_params[:email])
      post '/api/users', @user_params
      expect(json["error"]).to eq("Validation failed: Email has already been taken")
    end

    it "should return error messages if required fields are missing" do
      post '/api/users', email: @user_params[:email], password: @user_params[:password]
      expect(json["error"]).to eq("param is missing or the value is empty: full_name")
    end

    it "should look up gravatar for emails that have gravatars" do
      gravatar_user_params = {
        email: 'wjrobinson11@gmail.com',
        password: Faker::Internet.password(9),
        full_name: Faker::Name.name
      }
      post '/api/users', gravatar_user_params
      expect(json['avatar_url']).to eq(User.last.gravatar_url)
    end

    it "should not error on emails without gravatar" do
      non_gravatar_user_params = {
        email: 'thisisareallyfakeemail@example_test.com',
        password: Faker::Internet.password(9),
        full_name: Faker::Name.name
      }
      post '/api/users', non_gravatar_user_params
      expect(json['avatar_url']).to eq(User.last.gravatar_url)
    end
  end

  context "when showing a user" do
    it "should return 401 status if credentials are not sent" do
      user = create(:user)
      get "api/users/#{user.id}"
      expect(last_response.status).to eq(401)
    end

    it "should return user object if proper credentials are sent as params" do
      user = create(:user)
      get "api/users/#{user.id}", user_email: user.email, user_token: user.authentication_token

      expect(last_response.status).to eq(200)
      expect(json['email']).to eq(user.email)
    end

    it "should return user object if proper credentials are sent as headers" do
      user = create(:user)
      get "api/users/#{user.id}", nil, {'HTTP_X_USER_EMAIL' => user.email, 'HTTP_X_USER_TOKEN' => user.authentication_token}

      expect(last_response.status).to eq(200)
      expect(json['email']).to eq(user.email)
    end

    it "responds the same way to the /me route" do
      user = create(:user)
      get "api/users/me", nil, {'HTTP_X_USER_EMAIL' => user.email, 'HTTP_X_USER_TOKEN' => user.authentication_token}

      expect(last_response.status).to eq(200)
      expect(json['email']).to eq(user.email)
    end

    context "when logging in" do
      it "should return user object with authentication_token if using authorization basic" do
        password = 'pa33word'
        user = create(:user, password: password)
        get "/api/users/#{user.id}", nil, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
        expect(last_response.status).to eq(200)
        expect(json['authentication_token']).to eq(user.authentication_token)
      end

      it "should accept channel_id param and assign it if necessary" do
        password = 'pa33word'
        user = create(:user, password: password)
        channel_id = 'bc775f32-7a7c-4ee2-ac7c-a5e8bc97eb4a'
        get "/api/users/#{user.id}", {channel_id: channel_id}, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
        expect(json['channel_ids']).to eq([channel_id])
      end

      it "should return an error message if the wrong credentials are provided" do
        password = 'pa33word'
        user = create(:user, password: password)
        get "api/users/#{user.id}", nil, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("wrong@email.com",password)}

        expect(last_response.status).to eq(401)
        expect(last_response.body).to eq("{\"error\":\"Invalid email or password.\"}")
      end
    end
  end

  context "when updating a user" do
    it "should set the proper field on the user" do
      password = 'pa33word'
      user = create(:user, password: password)
      
      put "api/users/#{user.id}", {in_setup: false}, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
      expect(json['in_setup']).to eq(false)
    end

    it "should not duplicate channel_ids" do
      password = 'pa33word'
      user = create(:user, password: password)
      channel_id_1 = "channel_id_1"
      channel_id_2 = "channel_id_2"
      channel_id_3 = "channel_id_3"

      put "api/users/#{user.id}", {channel_id: channel_id_1}, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
      put "api/users/#{user.id}", {channel_id: channel_id_1}, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
      put "api/users/#{user.id}", {channel_id: channel_id_2}, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
      put "api/users/#{user.id}", {channel_id: channel_id_3}, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
      put "api/users/#{user.id}", {channel_id: channel_id_2}, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
      expect(json['channel_ids'].count).to eq(3)
    end

    it "pings gravatar if user updates his email" do
      password = 'pa33word'
      user = create(:user, email: 'test1@example_.com', password: password)
      new_email = 'wjrobinson11@gmail.com'

      put "api/users/#{user.id}", {email: new_email, password: password}, {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email,password)}
      expect(user.reload.gravatar_url).to_not be_nil
    end
  end
end





