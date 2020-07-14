require_relative "lib/artifactory/permissions/version"

Gem::Specification.new do |spec|
  spec.name = "artifactory-permissions"
  spec.version = Artifactory::Permissions::VERSION
  spec.authors = ["Thomas Scholz"]
  spec.email = ["thomas.scholz@rubyapps.ch"]

  spec.summary = %q{Ruby Lib for managing Artifactory PermissionTargets}
  spec.description = %q{Ruby Lib for managing Artifactory PermissionTargets}
  spec.homepage = "https://github.com/tscholz/artifactory-permissions"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.18"
end
