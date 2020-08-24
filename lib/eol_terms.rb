# frozen_string_literal: true

require 'eol_terms/version'
require 'yaml'

# Main continaer for the Gem.
module EolTerms
  class Error < StandardError; end
  class ValidationError < StandardError; end

  TERMS_YAML_FILENAME = File.join(File.dirname(__FILE__), '../', 'resources', 'terms.yml')
  URI_IDS_YAML_FILENAME = File.join(File.dirname(__FILE__), '../', 'resources', 'uri_ids.yml')
  USED_FOR_VALUES = %w[unknown measurement association value metadata].freeze
  VALID_FIELDS = %w[
    uri definition comment attribution ontology_information_url ontology_source_url used_for is_hidden_from_overview
    is_hidden_from_glossary is_text_only is_verbatim_only parent_uri synonym_of_uri
  ].freeze
  REQUIRED_FIELDS = %w[uri definition].freeze

  class << self
    def list(skip_validation = false)
      validate(true) unless skip_validation
      @list ||= YAML.load_file(TERMS_YAML_FILENAME)['terms'].map { |term| term.transform_keys(&:downcase) }
    end

    def uris(skip_validation = true)
      validate(true) unless skip_validation
      @uris ||= list(true).map { |term| term['uri'] }
    end

    # NOTE: you probably don't want to use this method; the values are meaningless. We needed an internal hash that was
    # NOT populated with the ID file, however, so this is really meant for internal use.
    def uri_hash(skip_validation = true)
      return @uri_hash if @uri_hash

      validate(true) unless skip_validation
      @uri_hash = {}
      uris(true).each { |uri| @uri_hash[uri] = true }
      @uri_hash
    end

    def uri_ids
      @uri_ids ||= YAML.load_file(URI_IDS_YAML_FILENAME)['uri_ids'].invert.transform_keys(&:downcase)
    end

    def validate(silent = false)
      @validator ||= Validator.new
      @validator.validate(silent)
    end

    def rebuild_ids
      validate(true)
      @checker = IdChecker.new
      @checker.rebuild_ids
    end
  end
end

# It seems weird to put these below the module, but the guide I was following had it here.
require 'eol_terms/validator'
require 'eol_terms/id_checker'
