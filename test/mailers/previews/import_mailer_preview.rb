# Preview all emails at http://localhost:3000/rails/mailers/import_mailer
class ImportMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/import_mailer/done
  def done
    user = User.first
    ImportMailer.done(user)
  end
end
