# frozen_string_literal: true

# You aren't going to read this.
module EolTerms
  # invoke with EolTerms.rebuild_ids
  class IdChecker
    def initialize
      @uris = EolTerms.uris(true)
      @uri_ids = EolTerms.uri_ids
      @next_id = next_available_id
      @preamble = "# DO NOT CHANGE THIS FILE.\n"\
                  "#\n"\
                  "#     *EVER.*\n"\
                  "#\n"\
                  "# Really: just don't touch this file. It's maintained by the codebase. Don't edit it manually. At all.\n"
    end

    def next_available_id
      next_id = 0
      @uri_ids.each { |_, val| next_id = val if val > next_id }
      next_id += 1 # Because, afer all, it is the NEXT id...\
    end

    def rebuild_ids
      rewrite_required = false
      @uris.each do |uri|
        unless @uri_ids.key?(uri.downcase)
          rewrite_required = true
          missing_uri(uri.downcase)
        end
      end
      rewrite_ids_file if rewrite_required
      puts "Done. Results saved in #{EolTerms::URI_IDS_YAML_FILENAME}"
    end

    def missing_uri(uri)
      @uri_ids[uri] = @next_id
      puts "Adding missing key: #{uri} (##{@next_id})"
      @next_id += 1
      true
    end

    def rewrite_ids_file
      File.open(EolTerms::URI_IDS_YAML_FILENAME, 'w') do |file|
        file.write @preamble
        file.write({ 'uri_ids' => @uri_ids }.to_yaml)
      end
    end
  end
end
