# frozen_string_literal: true

require_relative "lib/miti/version"
Gem::Specification.new do |spec|
  spec.name = "miti"
  spec.version = Miti::VERSION
  spec.authors = %w[xkshitizx sanzaymdr]
  spec.email = %w[kshitizlama03@gmail.com sanzaymanandhar99@gmail.com]

  spec.summary = "Date converter BS to AD and vice-versa."
  spec.description = "You can get current date by simply typing miti. It also converts date in AD to Nepali Date(BS)."
  # spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  spec.metadata = { "rubygems_mfa_required" => "true" }
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["README.md", "LICENSE",
                   "CHANGELOG.md", "lib/**/*.rb",
                   "lib/**/*.rake",
                   "miti.gemspec", ".github/*.md",
                   "Gemfile", "Rakefile"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license = "MIT"

  # Uncomment to register a new dependency of your gem
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency "zeitwerk", "~> 2.6.0"
end
