# frozen_string_literal: true

require "jekyll"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "jekyll-og-image"

require "minitest/autorun"

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
    source_dir("assets", "images", "og", "posts", "a-week-with-the-apple-watch.png")
  end

  def published_post_2_image_path
    source_dir("assets", "images", "og", "posts", "advanced-markdown-tips.png")
  end

  def draft_post_image_path
    source_dir("assets", "images", "og", "posts", "what-is-jekyll.png")
  end

  def page_image_path
    source_dir("assets", "images", "og", "pages", "about-us.png")
  end

  def collection_image_path
    source_dir("assets", "images", "og", "my_collection", "item1.png")
  end
end
