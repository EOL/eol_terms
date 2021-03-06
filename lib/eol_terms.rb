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

    def valid_fields
      Validator::VALID_FIELDS
    end

    def includes_uri?(uri)
      term_hash.key?(uri.downcase)
    end

    def by_uri(uri)
      term_hash[uri.downcase]
    end

    def term_hash
      return @term_hash if @term_hash

      @term_hash = {}
      list(true).each { |term| @term_hash[term['uri'].downcase] = term }
      @term_hash
    end

    def uri_ids
      @uri_ids ||= YAML.load_file(URI_IDS_YAML_FILENAME)['uri_ids']&.transform_keys(&:downcase)
      @uri_ids ||= {}
      @uri_ids
    end

    def validate(silent = false)
      @validator ||= Validator.new
      @validator.validate(silent)
    end

    def rebuild_ids(path = './resources/uri_ids.yml')
      validate(true)
      @checker = IdChecker.new(path)
      @checker.rebuild_ids
    end

    def inject_ids
      @uri_ids = EolTerms.uri_ids
      @list.each do |term|
        if term['uri'].nil?
          puts "Missing URI in term: "
          pp term
        end
        term['eol_id'] = @uri_ids[term['uri'].downcase].to_i
      end
      @list
    end

    # alias is a ruby keyword; use term_alias for the parameter name instead
    def alias_uri(term_alias)
      alias_hash(term_alias)['uri']
    end

    def alias_hash(term_alias)
      raise TypeError, "Term with alias #{term_alias} doesn't exist" unless terms_by_alias.include?(term_alias)

      terms_by_alias[term_alias]
    end

    def terms_by_alias
      return @terms_by_alias if @terms_by_alias

      @terms_by_alias = {}

      list(true).each do |term|
        @terms_by_alias[term['alias']] = term if term.include?('alias') && !term['alias'].nil? && !term['alias'].empty?
      end

      @terms_by_alias
    end
  end
  private_class_method :inject_ids
end

# It seems weird to put these below the module, but the guide I was following had it here.
require 'eol_terms/validator'
require 'eol_terms/id_checker'
