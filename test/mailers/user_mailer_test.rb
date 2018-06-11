require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = users(:admin)

    mail = UserMailer.welcome(user)
    assert_includes mail.subject, "Bienvenue"
    assert_equal [user.email], mail.to
    assert_equal ["contact@see-up.fr"], mail.from
    assert_match "Bonjour Jack Sparrow", mail.body.encoded
  end

end
