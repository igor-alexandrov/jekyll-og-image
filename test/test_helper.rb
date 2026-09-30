# frozen_string_literal: true

require "jekyll"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "jekyll-og-image"

require "minitest/autorun"
require "minitest/mock"

class Minitest::Test
  SOURCE_DIR = File.expand_path("source", __dir__)
  DEST_DIR   = File.expand_path("destination", __dir__)

  def source_dir(*files)
    File.join(SOURCE_DIR, *files)
  end

  def destination_dir(*files)
    File.join(DEST_DIR, *files)
  end

  def published_post_1_image_path
    source_dir("assets", "images", "og", "posts", "2018-01-12-a-week-with-the-apple-watch.png")
  end

  def published_post_2_image_path
    source_dir("assets", "images", "og", "posts", "2018-02-07-advanced-markdown-tips.png")
  end

  def draft_post_image_path
    source_dir("assets", "images", "og", "posts", "2018-02-10-what-is-jekyll.png")
  end

  def page_image_path
    source_dir("assets", "images", "og", "pages", "about.png")
  end

  def collection_image_path
    source_dir("assets", "images", "og", "my_collection", "item1.png")
  end

  def manifest_path
    source_dir("assets", "images", "og", ".jekyll-og-image.json")
  end

  # Reads through a buffer: libvips caches new_from_file by filename, so tests that
  # rewrite the same path would otherwise get a previous test's image.
  def load_image(path)
    Vips::Image.new_from_buffer(File.binread(path), "")
  end

  def solid_image(width, height, rgb)
    Vips::Image.black(width, height).new_from_image(rgb).copy(interpretation: :srgb)
  end

  def solid_png(width, height, rgb)
    solid_image(width, height, rgb).write_to_buffer(".png")
  end

  def rgb_at(image, x, y)
    image.getpoint(x, y).first(3).map(&:round)
  end
end
