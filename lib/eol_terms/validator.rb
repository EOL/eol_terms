# frozen_string_literal: true

# rake build ; rake install ; irb -r eol_terms
# EolTerms.validate
module EolTerms
  # You don't read these.
  class Validator
    USED_FOR_VALUES = %w[unknown measurement association value metadata].freeze
    VALID_FIELDS = %w[
      alias
      attribution
      definition
      eol_id
      is_hidden_from_select
      is_hidden_from_overview
      is_hidden_from_glossary
      is_text_only
      parent_uris
      units_term_uri
      name
      synonym_of_uri
      type
      uri
      is_symmetrical_association
      inverse_of_uri
      inverse_only
    ].freeze
    REQUIRED_FIELDS = %w[uri name].freeze

    def initialize
      @list = EolTerms.list(true)
    end

    # rubocop:disable Metrics/MethodLength
    def validate(silent = false)
      @problems = []
      @warnings = []
      @seen_uris = {}
      @list.each_with_index do |term, index|
        check_duplicate_uris(term, index)
        check_required_fields(term, index)
        check_for_illegal_fields(term, index)
        check_used_for_value(term, index)
        check_eol_id(term, index)
        check_parent_referential_integrity(term, index)
        check_synonym_referential_integrity(term, index)
        check_units_referential_integrity(term, index)
      end
      report(silent)
    end
    # rubocop:enable Metrics/MethodLength

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

    def check_eol_id(term, index)
      warning_in_term('Missing EOL ID', term, index) unless property?(term, 'eol_id')
    end

    def check_parent_referential_integrity(term, index)
      return unless property?(term, 'parent_uris')

      Array(term['parent_uris']).each do |uri|
        warning_in_term("Unrecognized parent URI `#{uri}`", term, index) unless EolTerms.includes_uri?(uri)
      end
    end

    def check_synonym_referential_integrity(term, index)
      return unless property?(term, 'synonym_of_uri')

      Array(term['synonym_of_uri']).each do |uri|
        warning_in_term("Unrecognized synonym URI `#{term['synonym_of_uri']}`", term, index) unless
          EolTerms.includes_uri?(uri)
      end
    end

    def check_units_referential_integrity(term, index)
      return unless property?(term, 'units_term_uri')

      warning_in_term("Unrecognized units_term URI `#{term['units_term_uri']}`", term, index) unless
        EolTerms.includes_uri?(term['units_term_uri'])
    end

    def problem_in_term(problem, term, index)
      @problems << "#{problem} in term #{index} <#{term['uri']}>"
    end

    def warning_in_term(problem, term, index)
      @warnings << "#{problem} in term #{index} <#{term['uri']}>"
    end

    def property?(term, property)
      # NOTE: this does NOT allow ' ' to be a valid "empty" string. No spaces
      # allowed.
      term.key?(property) && !term[property].nil? && (term[property].is_a?(Integer) || !term[property].empty?)
    end

    def report(silent = false)
      puts "WARNING: #{@warnings.join("\nWARNING: ")}\n" if @warnings.any? && !silent
      if @problems.any?
        puts "THERE WERE PROBLEMS:\n#{@problems.join("\n")}" unless silent
        raise EolTerms::ValidationError, 'Validation failed.'
      else
        puts 'Valid.' unless silent
      end
    end
  end
end
