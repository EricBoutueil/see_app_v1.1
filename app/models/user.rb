class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :send_welcome_email

  # for active_admin
  def name
    "#{last_name} #{first_name}"
  end

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_now
  end
end
