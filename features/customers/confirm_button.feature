Feature: confirm button appears when showdate selected

  As a customer
  So that I can choose a showdate before confirming tickets
  I want to only see the confirm button after I select a showdate

Background: show with at least one available performance

  Given there is a show named "Hairspray" with showdates:
  | date       | tickets_sold |
  | May 1, 8pm |            0 |
  | May 3, 8pm |          100 |
  And customer "Tom Foolery" has 5 of 5 open subscriber vouchers for "Hairspray"
  And I am logged in as customer "Tom Foolery"
  And I am on the home page for customer "Tom Foolery"

Scenario: button should not appear until showdate selected

  Then I should not see the button "confirm"

Scenario: button should appear after showdate selected
  When I select "2" from "number"
  And I select "Saturday, May 1, 8:00 PM" from "showdate_id"
  Then I should see the button "confirm"
