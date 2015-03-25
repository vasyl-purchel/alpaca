Feature: Alpaca can work with Visual Studio solutions
  In order to work with visual studio solutions I need to be sure
  that alpaca can be used as a build tool for them

  Scenario: Alpaca compile solution
    When I run "alpaca compile"
    Then alpaca update AssemblyInfo files for test_data/sln1/TestSolution.sln
    And alpaca build solution test_data/sln1/TestSolution.sln
    And alpaca do not build solution test_data/sln1/TestSolution.nobuild.sln
    And alpaca update AssemblyInfo files for test_data/sln2/SolutionName.sln
    And alpaca restore nuget packages for test_data/sln2/SolutionName.sln
    And alpaca build solution test_data/sln2/SolutionName.sln
    And the exit status should be 0

  Scenario: Alpaca test solution
    When I run "alpaca test -c"
    Then alpaca run tests for test_data/sln2/SolutionName.sln
    And alpaca generate unit test results test_data/sln2/TR/tests.xml
    And alpaca generate test coverage summary for test_data/sln2/TR/coverage.xml
    And the exit status should be 0

  Scenario: Alpaca report tests results
    When I run "alpaca report"
    Then alpaca generate coverage report test_data/sln1/TR/index.html

  Scenario: Alpaca pack solution
    When I run "alpaca pack"
    Then alpaca creates Sln1Tool.0.0.1.alpha.nupkg
    And alpaca commit test_data/sln1/.semver file to git
    And alpaca creates Sln2Project.1.0.0.rc.nupkg
    And alpaca commit test_data/sln1/.semver file to git
    And the exit status should be 0

  Scenario: Alpaca release package
    When I run "alpaca -p='**/TestSolution.sln' release --no-push"
    Then alpaca download latest package Sln1Tool.0.0.1.alpha
    And alpaca repack it as Sln1Tool.0.0.1
    And alpaca change inner Sln1Tool.nuspec version to 0.0.1
    And the exit status should be 0

  Scenario: Alpaca push package
    When I run "alpaca push"
    Then alpaca push package Sln1Tool.0.0.1.alpha.nupkg
    And alpaca push package Sln1Tool.0.0.1.alpha.nupkg
    And the exit status should be 0
