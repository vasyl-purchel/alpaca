Feature: Alpaca app kinda works
  In order to do anything with application I need to
  be sure that it still runs ok

  Scenario: App just runs
    When I get help for "alpaca"
    Then the exit status should be 0
