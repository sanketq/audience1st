@javascript
Feature: search with autocompletion

  As a box office worker
  So that I can help customers by phone
  I want to be able to search for a customer by various criteria

Background: I am logged in as boxoffice
  
  Given I am logged in as box office
  And the following customers exist: Frodo Baggins, Bilbo Baggins, Bob Bag

Scenario: search with multiple match

  When I fill "search_field" autocomplete field with "Bagg"
  Then I should see autocomplete choice "Bilbo Baggins" 
  And I should see autocomplete choice "Frodo Baggins"
  And I should see autocomplete choice "list all"
  But I should not see autocomplete choice "Bob Bag"
  When I select autocomplete choice "Bilbo Baggins"
  Then I should be on the home page for customer "Bilbo Baggins"

Scenario: search with no matches

  When I fill "search_field" autocomplete field with "xyz"
  Then I should see autocomplete choice "list all"

Scenario:search with other information
  Given the following Customers exist:
    | first_name | last_name | email               | street        | city | state |
    | Alex       | Fox       | afox@mail.com       | 11 Main St #1 |  SAF | CA    |
    | Armando    | Fox       | arfox@mail.com      | 11 Main St    |  SAF | CA    |
    | Bobby      | Boxer     | BB@email.com        | 123 Fox Hill  |  SAF | CA    |
    | Bob        | Bag       | BBB@email.com       | 23 Alexander  |  SAF | CA    |
    | Organ      | Milk      | dancingfox@mail.com | 100 bway      |  SAF | CA    |
    | Super      | Fox       | jewovnwo@mail.com   | 129 Mainly St |  SAF | CA    |
    | Evans      | Paul      | iamfox@mail.com     | 111 K St      |  SAF | CA    |
    | Siri       | Zpple     | fox@mail.com        | 112 k St      |  SAF | CA    |

  When I fill "search_field" autocomplete field with "Fox"
  Then I should see autocomplete choice "Armando Fox"
  And I should see autocomplete choice "Alex Fox"
  And I should see autocomplete choice "(1 more name matches)"
  And I should see autocomplete choice "Bobby Boxer(123 Fox Hill)"
  And I should see autocomplete choice "Organ Milk(dancingfox@mail.com)"
  And I should see autocomplete choice "(2 other matches)"
  And I should see autocomplete choice "list all"
  But I should not see autocomplete choice "Bob Bag"
  But I should not see autocomplete choice "Super Fox"