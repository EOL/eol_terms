# frozen_string_literal: true

require 'eol_terms/version'
require 'yaml'

# Main continaer for the Gem.
module EolTerms
  class Error < StandardError; end
  class ValidationError < StandardError; end

  TERMS_YAML_FILENAME = File.join(File.dirname(__FILE__), '../', 'resources', 'terms.yml')
  USED_FOR_VALUES = %w[unknown measurement association value metadata].freeze
  VALID_FIELDS = %w[
    uri definition comment attribution ontology_information_url ontology_source_url used_for is_hidden_from_overview
    is_hidden_from_glossary is_text_only is_verbatim_only parent_uri synonym_of_uri
  ].freeze
  REQUIRED_FIELDS = %w[uri definition].freeze

  class << self
    def list
      @list ||=
        YAML.load_file(TERMS_YAML_FILENAME)['terms'].map { |term| term.transform_keys(&:downcase) }
    end

    def uris
      @uris ||= list.map { |term| term['uri'] }
    end

    def uri_hash
      return @uri_hash if @uri_hash

      @uri_hash = {}
      @uris.each { |uri| @uri_hash[uri] = true }
      @uri_hash
    end

    # Method just runs through all applicable checks, method may be long:
    # rubocop:disable Metrics/MethodLength
    def validate
      @uris = {}
      @problems = []
      list.each_with_index do |term, index|
        check_duplicate_uris(term, index)
        check_required_fields(term, index)
        check_for_illegal_fields(term, index)
        check_used_for_value(term, index)
        check_parent_referential_integrity(term, index)
        check_synonym_referential_integrity(term, index)
      end
      report
    end
    # rubocop:enable Metrics/MethodLength

    def check_duplicate_uris(term, index)
      problem_in_term('Duplicate URI', term, index) if @uris.key?(term['uri'])
      @uris[term['uri']] = true
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

      problem_in_term("Unrecognized URI `#{term['parent_uri']}`", term, index) unless uri_hash.key?(term['parent_uri'])
    end

    def check_synonym_referential_integrity(term, index)
      return unless property?(term, 'synonym_of_uri')

      problem_in_term("Unrecognized URI `#{term['synonym_of_uri']}`", term, index) unless uri_hash.key?(term['synonym_of_uri'])
    end

    def problem_in_term(problem, term, index)
      @problems << "#{problem} in term #{index} <#{term['uri']}>"
    end

    def property?(term, property)
      # NOTE: this does NOT allow ' ' to be a valid "empty" string. No spaces
      # allowed.
      term.key?(property) && !term[property].nil? && !term[property].empty?
    end

    def report
      if @problems.any?
        puts "THERE WERE PROBLEMS:\n#{@problems.join("\n")}"
        raise EolTerms::ValidationError, 'Validation failed.'
      else
        puts 'Valid.'
      end
    end
  end
end
