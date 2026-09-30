# frozen_string_literal: true

require "test_helper"

class JekyllOgImage::LayoutTest < Minitest::Test
  def test_reference_canvas
    layout = layout_for({})

    assert_equal 80, layout.margin
    assert_equal 100, layout.header_top
    assert_equal 400, layout.header_dpi
    assert_equal 150, layout.content_dpi
    assert_equal 1040, layout.content_width
    assert_equal 1040, layout.header_width
    assert_equal 80, layout.bottom
  end

  def test_scales_with_canvas_width
    layout = layout_for("canvas" => { "width" => 600, "height" => 300 })

    assert_equal 40, layout.margin
    assert_equal 50, layout.header_top
    assert_equal 200, layout.header_dpi
    assert_equal 75, layout.content_dpi
    assert_equal 520, layout.content_width
  end

  def test_header_leaves_room_for_logo
    assert_equal 1040 - 150 - 30, layout_for("image" => "/logo.png").header_width
    assert_equal 520 - 75 - 15, layout_for("image" => "/logo.png", "canvas" => { "width" => 600 }).header_width
  end

  def test_bottom_includes_border
    assert_equal 90, layout_for("border_bottom" => { "width" => 10 }).bottom
    assert_equal 45, layout_for("border_bottom" => { "width" => 10 }, "canvas" => { "width" => 600 }).bottom
  end

  def test_scales_logo_and_border
    layout = layout_for(
      "canvas" => { "width" => 600 },
      "image" => { "path" => "/logo.png", "width" => 150, "height" => 100, "radius" => 50, "position" => { "x" => 80, "y" => 100 } },
      "border_bottom" => { "width" => 20 }
    )

    assert_equal [ 75, 50, 25 ], [ layout.logo_width, layout.logo_height, layout.logo_radius ]
    assert_equal({ x: 40, y: 50 }, layout.logo_position)
    assert_equal 10, layout.border_width
  end

  def test_logo_without_radius
    assert_nil layout_for("image" => { "radius" => nil }).logo_radius
  end

  def test_header_max_height_stops_above_metadata_line
    # 600 - 100 (header top) - 80 (bottom) - 25 (metadata line) - 30 (gap)
    assert_equal 365, layout_for({}).header_max_height(25)
  end

  private

  def layout_for(raw_config)
    JekyllOgImage::Layout.new(JekyllOgImage::Configuration.new(raw_config))
  end
end
