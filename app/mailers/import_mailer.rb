class ImportMailer < ApplicationMailer
  def done(user)
    @user = user

    mail to: @user.email, subject: "L'import est terminé"
  end

  def error(user, rows, exception)
    @user = user
    @exception = exception
    @formatted_rows = rows.map { |hash| format_row(hash) }.join("\n")

    mail to: @user.email, subject: "Échec de l'import"
  end

  private

  def format_row(hash)
    hash.map do |key, value|
      "#{key}: #{value}"
    end.join(", ")
  end
end
