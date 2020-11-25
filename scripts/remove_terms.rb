require 'csv'
require 'yaml'
require './scripts/terms_writer'

TO_REMOVE_CSV_PATH = 'scripts/values_with_no_connections.csv'
TERMS_FILE_PATH = 'resources/terms.yml'
NEW_TERMS_FILE_PATH = 'resources/modified_terms.yml'

data = YAML.load_file(TERMS_FILE_PATH)
terms_by_uri = data['terms'].map { |t| [t['uri'], t] }.to_h
ordered_uris = data['terms'].map { |t| t['uri'] }

count = 0
CSV.open(TO_REMOVE_CSV_PATH, headers: true) do |csv|
  csv.each do |row|
    uri = row['t.uri']

    if terms_by_uri.delete(uri)
      count += 1
    else
      puts "WARNING: term #{uri} missing from terms.yml, ignoring"
    end
  end
end

new_terms = ordered_uris.map { |uri| terms_by_uri[uri] }.compact

puts "removed #{count} terms, writing result to #{NEW_TERMS_FILE_PATH}"

TermsWriter.write(NEW_TERMS_FILE_PATH, new_terms)

puts 'done'

