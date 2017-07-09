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

class User < ActiveRecord::Base
  acts_as_token_authenticatable
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :full_name, presence: true

  has_many :mobile_notifications

  before_save :lookup_gravatar, if: :email_changed?

  DEFAULT_TIME_ZONE = "Central Time (US & Canada)"

  def gravatar?
    gravatar_check = "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}.png?d=404"
    uri = URI.parse(gravatar_check)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.code.to_i != 404
  end

  def construct_gravatar_url
    hash = Digest::MD5.hexdigest(email)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  def lookup_gravatar
    if gravatar?
      self.gravatar_url = construct_gravatar_url
    end
    true
  end

  def response_attributes
    _attributes = attributes
    _attributes['avatar_url'] ||= gravatar_url
    _attributes
  end
end
