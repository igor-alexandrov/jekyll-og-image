# frozen_string_literal: true

require_relative "lib/jekyll_og_image/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-og-image"
  spec.version = JekyllOgImage::VERSION
  spec.authors = [ "Igor Alexandrov" ]
  spec.email = [ "igor.alexandrov@gmail.com" ]

  spec.summary = "Jekyll plugin to generate GitHub-style open graph images"
  spec.homepage = "https://github.com/igor-alexandrov/jekyll-og-image"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.require_paths = [ "lib" ]

  spec.add_dependency "jekyll-seo-tag", "~> 2.8"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "ruby-vips", "~> 2.2.0"
  spec.add_runtime_dependency "jekyll", ">= 3.4", "< 5.0"

  # Add csv as development dependency to fix load errors in tests with Ruby 3.4+
  spec.add_development_dependency "csv"
end
