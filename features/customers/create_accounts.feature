# Reuse for new routes, pondering on abandoning the old one

Feature: Creating an account

  As an anonymous customer
  I want to be able to create an account
  So that I can be one of the cool kids

  Background: 

    Given I am not logged in
    And I am on the new customer page
    
  Scenario: New customer can create an account
    When I fill in the following:
      | Email            | john@doe.com  |
      | Password         | johndoe       |
      | Confirm Password | johndoe       |

    And I press "Register"
    Then I should be on the detailed info page for "john@doe.com"
    And I should see "Fields like this are required."

    Then I fill in the following:
      | First name       | John          |
      | Last name        | Doe           |
      | Street           | 123 Fake St   |
      | City             | San Francisco |
      | State            | CA            |
      | Zip              | 94131         |
      | Preferred phone  | 415-555-2222  |
      | Email            | john@doe.com  |

    And I press "Create My Account"
    Then I should see "Welcome, John Doe"
    And I should see "John Doe's Regular Tickets"

  Scenario: New customer cannot create account without providing email address

    When I fill in the following:
      | Password         | johndoe       |
      | Confirm Password | johndoe       |
    And I press "Register"
    Then account creation should fail with "Email is invalid"

  Scenario: New customer cannot create account with invalid email

    When I fill in the following:
    | Email            | invalid.address |
    | Password         | johndoe         |
    | Confirm Password | johndoe         |
    And I press "Register"
    Then account creation should fail with "Email is invalid"

  #TODO
  @wip
  Scenario: New customer cannot create account with duplicate email, pending

    Given customer "Tom Foolery" exists
    When I fill in the following:
    | Email            | tom@foolery.com |
    | Password         | tom             |
    | Confirm Password | tom             |
    And I press "Register"
    Then account creation should fail with "Email has already been taken"
    When I follow "Sign in as tom@foolery.com"

  Scenario: New customer cannot create account without providing password

    When I fill in the following:
    | Email | john@doe.com |
    And I press "Register"
    Then account creation should fail with "Password can't be blank"
    
  Scenario: New customer cannot create account with mismatched password confirmation

    When I fill in the following:
      | Email            | john@doe.com  |
      | Password         | johndoe       |
      | Confirm Password | johndo        |
    And I press "Register"
    Then account creation should fail with "Password confirmation doesn't match"

                                            
