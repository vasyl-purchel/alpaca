module Alpaca
  # The *Errors* module presents list of errors that may be thrown
  # while using Alpaca gem
  module Errors
    versioning = %w(SemVerFileNotFound InvalidSemVerFile
                    NotPreRelease WrongVersionDimension
                    AlreadyReleaseVersion AlreadyPreReleaseVersion
                    PreReleaseTagReachedFinalVersion)

    names = versioning
    names.each { |n| const_set(n, Class.new(StandardError)) }
  end
end
