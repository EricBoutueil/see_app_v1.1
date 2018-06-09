class ImportMailer < ApplicationMailer
  def done(user)
    @user = user

    mail to: @user.email, subject: "L'import est terminé"
  end
end
