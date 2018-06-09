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
end
