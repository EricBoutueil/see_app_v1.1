require 'test_helper'

class ImportMailerTest < ActionMailer::TestCase
  attr_reader :user
  setup do
    @user = user = users(:admin)
  end

  test "done" do
    mail = ImportMailer.done(user)
    assert_equal "L'import est terminé", mail.subject
    assert_equal [user.email], mail.to
    assert_match "mise à jour", mail.text_part.body.to_s
    assert_match "mise à jour", mail.html_part.body.to_s
  end

  test "error" do
    rows = [
      { "name" => "Marseille", "country" => "France", "address" => "Marseille" },
      { "name" => "Sète", "country" => "France", "address" => "Sète" },
    ]

    exception = StandardError.new("my error")
    exception.set_backtrace(caller)

    mail = ImportMailer.error(user, rows, exception)
    assert_equal "Échec de l'import", mail.subject
    assert_equal [user.email], mail.to

    text_body = mail.text_part.body.to_s
    html_body = mail.html_part.body.to_s

    [text_body, html_body].each do |body|
      assert_match "trace complète", body
      assert_match "minitest/test.rb", body
      assert_match "my error", body
      assert_match "name: Marseille, country: France, address: Marseille\n", body
    end
  end
end
