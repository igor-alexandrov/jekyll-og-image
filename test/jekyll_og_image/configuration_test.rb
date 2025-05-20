# frozen_string_literal: true

require "test_helper"

class JekyllOgImage::ConfigurationTest < Minitest::Test
  def setup
    @default_config = JekyllOgImage::Configuration.new({})
  end

  def test_merge_with_configuration_object
    config = JekyllOgImage::Configuration.new({ "output_dir" => "foo" })
    other = JekyllOgImage::Configuration.new({ "output_dir" => "bar" })

    assert_equal JekyllOgImage::Configuration.new({ "output_dir" => "bar" }), config.merge!(other)
  end

  def test_merge_with_hash
    config = JekyllOgImage::Configuration.new({ "output_dir" => "foo" })
    other = { "output_dir" => "bar" }

    assert_equal JekyllOgImage::Configuration.new({ "output_dir" => "bar" }), config.merge!(other)
  end

  def test_default_output_dir
    assert_equal "assets/images/og", @default_config.output_dir
  end

  def test_custom_output_dir
    config = JekyllOgImage::Configuration.new({ "output_dir" => "foo" })
    assert_equal "foo", config.output_dir
  end

  def test_default_force
    refute @default_config.force?
  end

  def test_custom_force
    config = JekyllOgImage::Configuration.new({ "force" => true })
    assert config.force?
  end

  def test_default_verbose
    refute @default_config.verbose?
  end

  def test_custom_verbose
    config = JekyllOgImage::Configuration.new({ "verbose" => true })
    assert config.verbose?
  end

  def test_default_skip_drafts
    assert @default_config.skip_drafts?
  end

  def test_custom_skip_drafts
    config = JekyllOgImage::Configuration.new({ "skip_drafts" => false })
    refute config.skip_drafts?
  end

  def test_default_canvas
    canvas = @default_config.canvas
    assert_instance_of JekyllOgImage::Configuration::Canvas, canvas
    assert_equal "#FFFFFF", canvas.background_color
    assert_nil canvas.background_image
    assert_equal 1200, canvas.width
    assert_equal 600, canvas.height
  end

  def test_custom_canvas
    config = JekyllOgImage::Configuration.new({
      "canvas" => {
        "background_color" => "#000000",
        "background_image" => "foo.png",
        "width" => 800,
        "height" => 400
      }
    })

    assert_equal JekyllOgImage::Configuration::Canvas.new(
      background_color: "#000000",
      background_image: "foo.png",
      width: 800,
      height: 400
    ), config.canvas
  end

  def test_canvas_with_custom_width_only
    config = JekyllOgImage::Configuration.new({ "canvas" => { "width" => 800 } })
    assert_equal 800, config.canvas.width
    assert_equal 600, config.canvas.height
  end

  def test_canvas_with_custom_height_only
    config = JekyllOgImage::Configuration.new({ "canvas" => { "height" => 400 } })
    assert_equal 1200, config.canvas.width
    assert_equal 400, config.canvas.height
  end

  def test_default_header
    header = @default_config.header
    assert_instance_of JekyllOgImage::Configuration::Header, header
    assert_equal "Helvetica, Bold", header.font_family
    assert_equal "#2f313d", header.color
  end

  def test_custom_header
    config = JekyllOgImage::Configuration.new({
      "header" => { "font_family" => "Arial", "color" => "#000000" }
    })

    assert_equal JekyllOgImage::Configuration::Header.new(
      font_family: "Arial",
      color: "#000000"
    ), config.header
  end

  def test_default_content
    content = @default_config.content
    assert_instance_of JekyllOgImage::Configuration::Content, content
    assert_equal "Helvetica, Regular", content.font_family
    assert_equal "#535358", content.color
  end

  def test_custom_content
    config = JekyllOgImage::Configuration.new({
      "content" => { "font_family" => "Arial", "color" => "#000000" }
    })

    assert_equal JekyllOgImage::Configuration::Content.new(
      font_family: "Arial",
      color: "#000000"
    ), config.content
  end

  def test_default_border_bottom
    assert_nil @default_config.border_bottom
  end

  def test_custom_border_bottom
    config = JekyllOgImage::Configuration.new({
      "border_bottom" => { "width" => 10, "fill" => "#000000" }
    })

    assert_equal JekyllOgImage::Configuration::Border.new(
      width: 10,
      fill: "#000000"
    ), config.border_bottom
  end

  def test_default_margin_bottom
    assert_equal 80, @default_config.margin_bottom
  end

  def test_margin_bottom_with_border
    config = JekyllOgImage::Configuration.new({
      "border_bottom" => { "width" => 10 }
    })
    assert_equal 90, config.margin_bottom
  end

  def test_default_image
    assert_nil @default_config.image
  end

  def test_custom_image
    config = JekyllOgImage::Configuration.new({ "image" => "foo.png" })
    assert_equal "foo.png", config.image
  end

  def test_default_domain
    assert_nil @default_config.domain
  end

  def test_custom_domain
    config = JekyllOgImage::Configuration.new({ "domain" => "foo.com" })
    assert_equal "foo.com", config.domain
  end
end
