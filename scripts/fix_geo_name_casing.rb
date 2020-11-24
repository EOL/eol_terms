# run from top-level eol_terms directory
require 'yaml'
require 'set'
require 'json'

ORIG_FILE_PATH = 'resources/terms.yml'
NEW_FILE_PATH = 'resources/fixed_terms.yml'
GEO_URIS_FILE_PATH = 'scripts/geo_terms.json'
LINE_WIDTH = 1_000_000 # don't break lines
GEO_URI_REGEXP = /.*(geonames|mrgid).*/

def titleize!(word)
  word.gsub!(/\w+/) do |word|
    word.capitalize
  end
end

def match_geo?(uri)
  uri =~ GEO_URI_REGEXP
end

def any_match_geo?(uris)
  return if uris.nil?

  uris.each do |uri|
    if match_geo?(uri)
      return true
    end
  end

  false
end

geo_uris = Set.new(JSON.parse(File.read(GEO_URIS_FILE_PATH))["data"].flatten)
puts "Read #{geo_uris.size} uris from file"

terms = YAML.load_file(ORIG_FILE_PATH)["terms"]

geo_count = 0
other_count = 0

terms.each do |term|
  uri = term["uri"]
  
  if term.include?("name")
    if geo_uris.include?(uri)
      geo_count += 1
      titleize!(term["name"])
    else
      other_count += 1
      term["name"].downcase!
    end
  end
end

File.open(NEW_FILE_PATH, "w") do |newfile|
  newfile.write(YAML.dump(terms, line_width: LINE_WIDTH))
end

puts "Title-cased #{geo_count} term names and downcased #{other_count}. Output is in #{NEW_FILE_PATH}"

