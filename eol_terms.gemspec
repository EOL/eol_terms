require_relative 'lib/eol_terms/version'

Gem::Specification.new do |spec|
  spec.name          = "eol_terms"
  spec.version       = EolTerms::VERSION
  spec.authors       = ["JRice"]
  spec.email         = ["jrice@eol.org"]

  spec.summary       = %q{A very basic repository for terms, their URIs, and their properties that EOL maintains on the site.}
  spec.description   = %q{For use in biodiversity informatics where URIs are commonly used to describe traits.}
  spec.homepage      = "https://eol.org"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/EOL/eol_terms"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^sh/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
