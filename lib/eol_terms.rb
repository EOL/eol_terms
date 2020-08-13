require "eol_terms/version"

module EolTerms
  class Error < StandardError; end
  TERMS_YAML_FILENAME = File.join(File.dirname(__FILE__), '../../', 'resources', 'terms.yml')
  def self.hi
    puts "Hi"
  end
end
