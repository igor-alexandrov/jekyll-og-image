# frozen_string_literal: true

require "test_helper"

class JekyllOgImageTest < Minitest::Test
  def read
    @site = Jekyll::Site.new(Jekyll.configuration(@config))
    @og_image = JekyllOgImage::Generator.new(@site.config)

    @site.read
  end

  def generate_images
    @og_image.generate(@site)
  end

  def setup
    @config = Jekyll::Utils.deep_merge_hashes(
      Jekyll::Configuration::DEFAULTS,
      {
        "source" => source_dir,
        "destination" => destination_dir,
        "plugins" => [ "jekyll-og-image" ]
      }
    )
  end

  def teardown
    FileUtils.rm_rf(File.join(source_dir, "assets"))
  end

  def test_version_number
    refute_nil ::JekyllOgImage::VERSION
  end

  def test_generate_og_images_with_default_config
    read
    generate_images

    assert File.exist?(published_post_1_image_path)
    assert File.exist?(published_post_2_image_path)

    refute File.exist?(draft_post_image_path)
    refute File.exist?(page_image_path)
    refute File.exist?(collection_image_path)
  end

  def test_generate_og_images_only_for_pages
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => {
        "collections" => [ "pages" ]
      }
    )

    read
    generate_images

    assert File.exist?(page_image_path)

    refute File.exist?(published_post_1_image_path)
    refute File.exist?(published_post_2_image_path)
    refute File.exist?(draft_post_image_path)
    refute File.exist?(collection_image_path)
  end

  def test_generate_og_images_only_for_collections
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => {
        "collections" => [ "my_collection" ]
      },
      "collections" => {
        "my_collection" => { "output" => true }
      }
    )

    read
    generate_images

    assert File.exist?(collection_image_path)

    refute File.exist?(published_post_1_image_path)
    refute File.exist?(published_post_2_image_path)
    refute File.exist?(draft_post_image_path)
    refute File.exist?(page_image_path)
  end

  def test_generate_og_images_for_posts_and_pages
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => {
        "collections" => [ "posts", "pages" ]
      },
    )

    read
    generate_images

    assert File.exist?(published_post_1_image_path)
    assert File.exist?(published_post_2_image_path)
    assert File.exist?(page_image_path)

    refute File.exist?(draft_post_image_path)
    refute File.exist?(collection_image_path)
  end

  def test_front_matter_overrides
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => {
        "collections" => [ "posts", "pages" ]
      },
    )

    read

    about_page = @site.pages.find { |p| p.name == "about.md" }
    about_page.data["og_image"] = { "enabled" => false }

    generate_images

    assert File.exist?(published_post_1_image_path)
    assert File.exist?(published_post_2_image_path)

    refute File.exist?(draft_post_image_path)
    refute File.exist?(page_image_path)
    refute File.exist?(collection_image_path)
  end
end
