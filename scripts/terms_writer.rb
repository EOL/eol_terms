module TermsWriter
  LINE_WIDTH = 1_000_000 # don't break lines

  class << self
    def write(path, terms)
      File.open(path, 'w') do |f|
        f.write(YAML.dump({ 'terms' => terms }, line_width: LINE_WIDTH))
      end
    end
  end
end
