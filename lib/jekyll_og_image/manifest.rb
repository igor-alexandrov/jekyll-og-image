# frozen_string_literal: true

require "json"

# Remembers a digest of the inputs each image was generated from, so images are
# regenerated only when something that affects them changes.
#
# Stored as a dotfile in the output directory, which Jekyll never publishes.
class JekyllOgImage::Manifest
  FILENAME = ".jekyll-og-image.json"

  def initialize(dir)
    @path = File.join(dir, FILENAME)
    @previous = load
    @current = {}
  end

  def fresh?(image_path, digest)
    @current.fetch(image_path) { @previous[image_path] } == digest
  end

  def record(image_path, digest)
    @current[image_path] = digest
  end

  # Writes the images recorded during this build. Entries for images that weren't
  # recorded (deleted or disabled documents) are dropped.
  def save
    entries = @current.sort.to_h
    return if entries == @previous

    FileUtils.mkdir_p(File.dirname(@path))
    File.write(@path, JSON.pretty_generate(entries))
  end

  private

  def load
    JSON.parse(File.read(@path))
  rescue Errno::ENOENT, JSON::ParserError
    {}
  end
end
