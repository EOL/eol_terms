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
    def list(skip_validation = false)
      validate(true) unless skip_validation
      @list ||=
        YAML.load_file(TERMS_YAML_FILENAME)['terms'].map { |term| term.transform_keys(&:downcase) }
    end

    def uris(skip_validation = true)
      validate(true) unless skip_validation
      @uris ||= list(true).map { |term| term['uri'] }
    end

    def uri_hash(skip_validation = true)
      return @uri_hash if @uri_hash

      validate(true) unless skip_validation
      @uri_hash = {}
      uris(true).each { |uri| @uri_hash[uri] = true }
      @uri_hash
    end

    def validate(silent = false)
      @validator ||= Validator.new
      @validator.validate(silent)
    end
  end
end

# It seems weird to put this below the module, but the guide I was following had it here.
require 'eol_terms/validator'
