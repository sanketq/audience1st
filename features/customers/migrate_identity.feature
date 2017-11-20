Feature: migrate the email and password column into omniauth-identity

  As a user
  So that I can login to with my old password and email
  I want my record to be kept in Identity and use identity login system later

Background:
  Given the following Customers exist:
  | first_name | last_name | email          | created_by_admin | password | password_confirmation | last_login | updated_at |
  | MaryJane   | Weigandt  | mjw@mail.com   | true             | mary     | mary                  | 2011-01-03 | 2011-01-01 |
  | Janey      | Weigandt  | janey@mail.com | false            | blurgle  | blurgle               | 2010-01-01 | 2010-01-01 |
  | Janey      | Weigandt  | janey@mail.com | false            | blurgle  | blurgle               | 2010-01-01 | 2010-01-01 |


Scenario: Customer will have record in identity after login
  Given I have never login before with email "mjw@mail.com" and password "mary"
  And   I cannot login with Identity with password "mary"
  Then I login with email "mjw@mail.com" and password "mary" in the old way
  Then I log out
  And I can login with Identity with email "mjw@mail.com" and password "mary"

