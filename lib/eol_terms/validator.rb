# frozen_string_literal: true

# rake build ; rake install ; irb -r eol_terms
# EolTerms.validate
module EolTerms
  # You don't read these.
  class Validator
    def initialize
      @list = EolTerms.list(true)
      @seen_uris = {}
      @problems = []
      @uri_hash = EolTerms.uri_hash(true)
    end

    def validate(silent = false)
      @list.each_with_index do |term, index|
        check_duplicate_uris(term, index)
        check_required_fields(term, index)
        check_for_illegal_fields(term, index)
        check_used_for_value(term, index)
        check_parent_referential_integrity(term, index)
        check_synonym_referential_integrity(term, index)
      end
      report(silent)
    end

    def check_duplicate_uris(term, index)
      problem_in_term('Duplicate URI', term, index) if @seen_uris.key?(term['uri'])
      @seen_uris[term['uri']] = true
    end

    def check_required_fields(term, index)
      REQUIRED_FIELDS.each do |field|
        problem_in_term("Missing required #{field}", term, index) unless property?(term, field)
      end
    end

    def check_for_illegal_fields(term, index)
      term.keys.each do |field|
        problem_in_term("Illegal field `#{field}`", term, index) unless VALID_FIELDS.include?(field)
      end
    end

    def check_used_for_value(term, index)
      return unless property?(term, 'used_for')

      problem_in_term("Illegal used_for value `#{term['used_for']}`", term, index) unless
        USED_FOR_VALUES.include?(term['used_for'])
    end

    def check_parent_referential_integrity(term, index)
      return unless property?(term, 'parent_uri')

      problem_in_term("Unrecognized URI `#{term['parent_uri']}`", term, index) unless @uri_hash.key?(term['parent_uri'])
    end

    def check_synonym_referential_integrity(term, index)
      return unless property?(term, 'synonym_of_uri')

      problem_in_term("Unrecognized URI `#{term['synonym_of_uri']}`", term, index) unless
        @uri_hash.key?(term['synonym_of_uri'])
    end

    def problem_in_term(problem, term, index)
      @problems << "#{problem} in term #{index} <#{term['uri']}>"
    end

    def property?(term, property)
      # NOTE: this does NOT allow ' ' to be a valid "empty" string. No spaces
      # allowed.
      term.key?(property) && !term[property].nil? && !term[property].empty?
    end

    def report(silent = false)
      if @problems.any?
        puts "THERE WERE PROBLEMS:\n#{@problems.join("\n")}" unless silent
        raise EolTerms::ValidationError, 'Validation failed.'
      else
        puts 'Valid.' unless silent
      end
    end
  end
end
