# frozen_string_literal: true

require 'eol_terms/version'
require 'yaml'

# Main continaer for the Gem.
module EolTerms
  class Error < StandardError; end
  class ValidationError < StandardError; end

  TERMS_YAML_FILENAME = File.join(File.dirname(__FILE__), '../', 'resources', 'terms.yml')
  URI_IDS_YAML_FILENAME = File.join(File.dirname(__FILE__), '../', 'resources', 'uri_ids.yml')

  class << self
    def list(skip_validation = false)
      return @list if @list

      # TODO: Consider moving valid to a class property so we don't run it multiple times unless we are asked to.
      validate(true) unless skip_validation
      @list = YAML.load_file(TERMS_YAML_FILENAME)['terms'].map { |term| term.transform_keys(&:downcase) }
      inject_ids
    end

    def uris(skip_validation = true)
      return @uris if @uris

      validate(true) unless skip_validation
      @uris = list(true).map { |term| term['uri'] }
    end

    def includes_uri?(uri)
      unless @uri_hash
        @uri_hash = {}
        uris(true).each { |uri| @uri_hash[uri] = true }
      end
      @uri_hash.key?(uri)
    end

    def uri_ids
      @uri_ids ||= YAML.load_file(URI_IDS_YAML_FILENAME)['uri_ids'].transform_keys(&:downcase)
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

    def inject_ids
      @uri_ids = EolTerms.uri_ids
      @list.each do |term|
        term['eol_id'] = @uri_ids[term['uri']]
      end
      @list
    end
  end
  private_class_method :inject_ids
end

# It seems weird to put these below the module, but the guide I was following had it here.
require 'eol_terms/validator'
require 'eol_terms/id_checker'
