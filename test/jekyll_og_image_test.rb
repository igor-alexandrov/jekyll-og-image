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

    assert_nil about_page.data["image"]
  end

  def test_disabled_site_does_not_reference_missing_images
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => { "enabled" => false }
    )

    read
    generate_images

    refute File.exist?(published_post_1_image_path)
    assert_nil find_post("a-week-with-the-apple-watch").data["image"]
  end

  def test_title_and_metadata_with_markup_characters
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => {
        "header" => { "prefix" => "<Blog> " },
        "metadata" => { "fields" => [ "date", "tags", "description" ] },
        "domain" => "example.com"
      }
    )

    read
    post = find_post("a-week-with-the-apple-watch")
    post.data["title"] = "Rails & Hotwire <3"
    post.data["tags"] = [ "c++", "a<b" ]
    post.data["description"] = "Tips & tricks"

    generate_images

    assert File.exist?(published_post_1_image_path)
  end

  def test_border_bottom_with_single_color_fill
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => { "border_bottom" => { "width" => 20, "fill" => "#4285F4" } }
    )

    read
    generate_images

    image = Vips::Image.new_from_file(published_post_1_image_path)
    assert_equal [ 66, 133, 244 ], image.getpoint(600, 590).first(3).map(&:round)
  end

  def test_image_with_gravity_and_position_from_yaml
    FileUtils.mkdir_p(source_dir("assets"))
    Vips::Image.black(100, 100)
      .new_from_image([ 255, 0, 0 ])
      .copy(interpretation: :srgb)
      .write_to_file(source_dir("assets", "logo.png"))

    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => YAML.safe_load(<<~YAML)
        image:
          path: /assets/logo.png
          gravity: se
          position:
            x: 10
            y: 20
      YAML
    )

    read
    generate_images

    # A 150x150 logo anchored to the bottom-right corner, 10px from the right and 20px from the bottom
    image = Vips::Image.new_from_file(published_post_1_image_path)
    assert_equal [ 255, 0, 0 ], image.getpoint(1115, 505).first(3).map(&:round)
  end

  def test_missing_logo_warns_and_generates_image_without_it
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => { "image" => "/assets/missing-logo.png" }
    )

    read
    warnings = capture_warnings { generate_images }

    assert File.exist?(published_post_1_image_path)
    assert_equal [ "og_image.image.path file not found: /assets/missing-logo.png, skipping it" ], warnings
  end

  def test_missing_background_image_warns_and_generates_image_without_it
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => { "canvas" => { "background_image" => "/assets/missing-background.png" } }
    )

    read
    warnings = capture_warnings { generate_images }

    assert File.exist?(published_post_1_image_path)
    assert_equal [ "og_image.canvas.background_image file not found: /assets/missing-background.png, skipping it" ], warnings
  end

  def test_does_not_register_duplicate_static_files_for_existing_images
    FileUtils.mkdir_p(File.dirname(published_post_1_image_path))
    File.binwrite(published_post_1_image_path, "stub")

    read
    generate_images

    matching_files = @site.static_files.select do |file|
      file.relative_path == "/assets/images/og/posts/a-week-with-the-apple-watch.png"
    end

    assert_equal 1, matching_files.size
  end

  def test_metadata_includes_short_description_when_it_fits
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => {
        "collections" => [ "posts" ],
        "metadata" => { "fields" => [ "date", "description" ] },
        "domain" => "example.com"
      },
    )

    read
    post = @site.posts.docs.first
    post.data["description"] = "Short description"
    config = JekyllOgImage::Configuration.new(@config["og_image"])

    metadata_text = @og_image.send(:metadata_text_for, post, config)

    assert_includes metadata_text, "Short description"
  end

  def test_metadata_skips_description_when_it_does_not_fit
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => {
        "collections" => [ "posts" ],
        "metadata" => { "fields" => [ "date", "description" ] },
        "domain" => "example.com"
      },
    )

    read
    post = @site.posts.docs.first
    post.data["description"] = "This is a very long description intended to exceed the single-line metadata width " \
      "and therefore should not be included in the generated metadata footer text."
    config = JekyllOgImage::Configuration.new(@config["og_image"])

    metadata_text = @og_image.send(:metadata_text_for, post, config)

    refute_includes metadata_text, "This is a very long description"
  end

  def test_domain_y_position_aligns_with_metadata_line
    @config = Jekyll::Utils.deep_merge_hashes(
      @config,
      "og_image" => {
        "collections" => [ "posts" ],
        "domain" => "example.com",
        "metadata" => { "fields" => [ "date" ] }
      },
    )

    read
    post = @site.posts.docs.first
    config = JekyllOgImage::Configuration.new(@config["og_image"])

    canvas = Class.new do
      attr_reader :y_position

      def text(_message, **_opts)
        result = yield(nil, nil)
        @y_position = result[:y]
        self
      end
    end.new

    @og_image.send(:add_domain, canvas, post, config)

    assert_equal config.margin_bottom, canvas.y_position
  end

  private

  def capture_warnings
    warnings = []
    Jekyll.logger.stub(:warn, ->(_topic, message) { warnings << message }) { yield }
    warnings
  end

  def find_post(slug)
    @site.posts.docs.find { |post| post.data["slug"] == slug }
  end
end
