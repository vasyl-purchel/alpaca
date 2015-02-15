module Alpaca
  # The *Errors* module presents list of errors that may be thrown
  # while using Alpaca gem
  module Errors
    names = %w(ConfigNotFound ConfigurationIsNeitherFileNorHash
               SemVerFileNotFound InvalidSemVerFile InvalidSemVerArguments
               PreReleaseTagNotFound NotPreRelease WrongVersionDimension
               AlreadyReleaseVersion AlreadyPreReleaseVersion)
    names.each { |n| const_set(n, Class.new(StandardError)) }
  end
end
