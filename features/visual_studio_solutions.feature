@windows
Feature: Alpaca can work with Visual Studio solutions
  In order to work with visual studio solutions I need to be sure
  that alpaca can be used as a build tool for them

  Scenario: Alpaca compile solution
    When I run "alpaca compile"
    And alpaca build file TestSolution.exe
    And alpaca do not build file TestSolution.nobuild.exe
    And alpaca restore nuget packages for test_data/sln2/SolutionName.sln
    And alpaca build file ProjectName.dll
    And alpaca build file ProjectName2.dll
    And the exit status should be 0

  Scenario: Alpaca test solution
    When I run "alpaca test"
    And solution has failing unit test
    Then the exit status should be 256

  Scenario: Alpaca test with coverage solution
    When I run "alpaca test -c"
    Then alpaca generate unit test results test_data/sln2/.tests/UnitTestsResult.xml
    And alpaca generate test coverage summary test_data/sln2/.tests/coverage.xml
    And the exit status should be 0

  Scenario: Alpaca report tests results
    When I run "alpaca report"
    Then alpaca generate unit tests report test_data/sln2/.tests/UnitTestsResult.html
    Then alpaca generate coverage report test_data/sln2/.tests/index.htm

  Scenario: Alpaca pack solution
    When I run "alpaca pack"
    Then alpaca creates test_data/sln1/.output/TestData.FirstSolution.0.0.1-alpha.nupkg
    Then alpaca creates test_data/sln1/.output/TestData.FirstSolution.0.0.1-alpha.symbols.nupkg
    And alpaca creates test_data/sln2/.output/TestData.SecondSolution.2.0.11.nupkg
    And alpaca creates test_data/sln2/.output/TestData.SecondSolution.2.0.11.symbols.nupkg
    And the exit status should be 0

  @teardown_changes
  Scenario: Alpaca release package
    When I run "alpaca -p '**/TestSolution.sln' release --no-push"
    Then alpaca creates test_data/sln1/.output/TestData.FirstSolution.0.0.1.nupkg
    And the exit status should be 0
