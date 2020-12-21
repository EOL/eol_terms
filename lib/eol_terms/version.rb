module EolTerms
  # NOTE: Our versions are not "semantic" because we basically just patch EVERY TIME. But we had trouble with using
  # double-digit patch numbers (bundler wasn't seeing 12 as being updatable from 11), so we're going back to single
  # digits, even though it means we'll have inappropriate minor and major numbers. Not worth the hassle.
  VERSION = '0.7.01'.freeze
end
