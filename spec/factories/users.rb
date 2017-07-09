# == Schema Information
#
# Table name: users
#
#  authentication_token      :string(30)
#  avatar_image              :text
#  avatar_url                :string
#  channel_ids               :text             default([]), is an Array
#  created_at                :datetime         not null
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :inet
#  email                     :string
#  encrypted_password        :string           default(""), not null
#  first_name                :string
#  full_name                 :string
#  gravatar_url              :string
#  id                        :integer          not null, primary key
#  in_setup                  :boolean
#  last_name                 :string
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :inet
#  phone                     :string
#  phone_verification_code   :string
#  phone_verified            :boolean
#  receive_app_notifications :boolean
#  remember_created_at       :datetime
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  sign_in_count             :integer          default(0), not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

FactoryGirl.define do
  factory :user do
    email    { Faker::Internet.email }
    password { Faker::Internet.password(9) }
    full_name { Faker::Name.name }
  end
end
