# frozen_string_literal: true

# You aren't going to read this.
module EolTerms
  # I am sure no one reads class comments, but they are "required"
  class IdChecker
    def initialize
      @uris = EolTerms.uris(true)
      @uri_ids = EolTerms.uri_ids
      @next_id = next_available_id
      @uri_ids.each { |_, val| @next_id = val if val > @next_id }
      @next_id += 1 # Because, afer all, it is the NEXT id...
      @preamble = "# DO NOT CHANGE THIS FILE.\n"\
                  "#\n"\
                  "#     *EVER.*\n"\
                  "#\n"\
                  "# Really: just don't touch this file. It's maintained by the codebase. Don't edit it manually. At all.\n"
    end

    def next_available_id
      next_id = 0
      @uri_ids.each { |_, val| @next_id = val if val > next_id }
      next_id += 1 # Because, afer all, it is the NEXT id...\
    end

    def rebuild_ids
      missing_keys = []
      @uris.each do |uri|
        missing_keys << missing_uri(uri.downcase) unless @uri_ids.key?(uri.downcase)
      end
      rewrite_ids_file unless missing_keys.empty?
      puts "Done. Results saved in #{EolTerms::URI_IDS_YAML_FILENAME}"
    end

    def missing_uri(uri)
      @uri_ids[uri] = @next_id
      puts "Adding missing key: #{uri} (##{@next_id})"
      @next_id += 1
      uri
    end

    def rewrite_ids_file
      File.open(EolTerms::URI_IDS_YAML_FILENAME, 'w') do |file|
        file.write @preamble
        file.write({ 'uri_ids' => @uri_ids }.to_yaml)
      end
    end
  end
end
