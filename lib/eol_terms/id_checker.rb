# frozen_string_literal: true
module EolTerms
  # invoke with EolTerms.rebuild_ids('/Users/jeremyrice/git/eol_terms/resources/uri_ids.yml')
  class IdChecker
    def initialize(path)
      @path = path
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
      puts "There are currently #{@uri_ids.size} URI ID keys."
      rewrite_required = false
      @uris.each do |uri|
        unless @uri_ids.key?(uri.downcase)
          rewrite_required = true
          missing_uri(uri.downcase)
        end
      end
      rewrite_ids_file if rewrite_required
      puts "There are now #{@uri_ids.size} URI ID keys."
      puts "Done. Results saved in #{@path}"
    end

    def missing_uri(uri)
      @uri_ids[uri] = @next_id
      puts "Adding missing key: #{uri} (##{@next_id})"
      @next_id += 1
      true
    end

    def rewrite_ids_file
      File.open(@path, 'w') do |file|
        file.write @preamble
        file.write({ 'uri_ids' => @uri_ids }.to_yaml)
      end
    end
  end
end
