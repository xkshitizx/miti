# frozen_string_literal: true

require_relative "lib/miti/version"
Gem::Specification.new do |spec|
  spec.name = "miti"
  spec.version = Miti::VERSION
  spec.authors = %w[xkshitizx sanzaymdr]
  spec.email = %w[kshitizlama03@gmail.com sanzaymanandhar99@gmail.com]

  spec.summary = "Date converter BS to AD and vice-versa."
  spec.description = "Convert English date(AD) to Nepali date(BS) and vice-versa."
  spec.homepage = "https://github.com/xkshitizx/miti"
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["README.md", "LICENSE",
                   "CHANGELOG.md", "lib/**/*.rb",
                   "lib/**/*.rake", "docs/*.md",
                   "miti.gemspec", ".github/*.md",
                   "Gemfile", "Rakefile"]
  spec.metadata = {
    # "allowed_push_host" = "TODO: Set to your gem server 'https://example.com'",
    "bug_tracker_uri" => "https://github.com/xkshitizx/miti/issues",
    "changelog_uri" => "https://github.com/xkshitizx/miti/blob/main/CHANGELOG.md",
    "homepage_uri" => "https://github.com/xkshitizx/miti",
    "source_code_uri" => "https://github.com/xkshitizx/miti/tree/v#{Miti::VERSION}",
    "rubygems_mfa_required" => "true"
  }
  spec.bindir = "exe"
  spec.executables = ["miti"]
  spec.require_paths = ["lib"]
  spec.license = "MIT"

  spec.add_dependency "thor", "~> 1.2", ">= 1.2.2"
  # Uncomment to register a new dependency of your gem
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
