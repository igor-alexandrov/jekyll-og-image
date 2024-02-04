# frozen_string_literal: true

require "jekyll"
require "jekyll-og-image"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  SOURCE_DIR = File.expand_path("source", __dir__)
  DEST_DIR   = File.expand_path("destination", __dir__)

  def source_dir(*files)
    File.join(SOURCE_DIR, *files)
  end

  def destination_dir(*files)
    File.join(DEST_DIR, *files)
  end
end
