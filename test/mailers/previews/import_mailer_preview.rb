# Preview all emails at http://localhost:3000/rails/mailers/import_mailer
class ImportMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/import_mailer/done
  def done
    user = User.first
    ImportMailer.done(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/import_mailer/error
  def error
    rows = [
      { "name" => "Marseille", "country" => "France", "address" => "Marseille" },
      { "name" => "Sète", "country" => "France", "address" => "Sète" },
    ]

    exception = StandardError.new("my error")
    exception.set_backtrace(caller)

    user = User.first
    ImportMailer.error(user, rows, exception)
  end
end
