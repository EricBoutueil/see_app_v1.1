class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    @user = user  # Instance variable => available in view

    mail(to: @user.email, subject: 'Bienvenue dans le service Port Traffic proposé par See\'up')
    # This will render a view in `app/views/user_mailer`!
  end
end
