# frozen_string_literal: true

class JekyllOgImage::Generator < Jekyll::Generator
  safe true

  def generate(site)
    base_path = File.join(JekyllOgImage.config.output_dir, "posts")

    FileUtils.mkdir_p File.join(site.config["source"], base_path)

    site.posts.docs.each do |post|
      next if post.draft? && JekyllOgImage.config.skip_drafts?

      path = File.join(site.config["source"], base_path, "#{post.data['slug']}.png")

      if !File.exist?(path) || JekyllOgImage.config.force?
        Jekyll.logger.info "Jekyll Og Image:", "Generating image #{path}" if JekyllOgImage.config.verbose?
        generate_image_for_post(site, post, path)
      else
        Jekyll.logger.info "Jekyll Og Image:", "Skipping image generation #{path} as it already exists." if JekyllOgImage.config.verbose?
      end

      post.data["image"] ||= {
        "path" => File.join(base_path, "#{post.data['slug']}.png"),
        "width" => 1200,
        "height" => 600,
        "alt" => post.data["title"]
      }
    end
  end

  private

  def generate_image_for_post(site, post, path)
    config = JekyllOgImage.config.merge!(post.data["og_image"])

    canvas = generate_canvas(site, config)
    canvas = add_border_bottom(canvas, config) if config.border_bottom
    canvas = add_image(canvas, File.read(File.join(site.config["source"], config.image))) if config.image
    canvas = add_header(canvas, post, config)
    canvas = add_publish_date(canvas, post, config)
    canvas = add_tags(canvas, post, config) if post.data["tags"].any?
    canvas = add_domain(canvas, post, config) if config.domain

    canvas.save(path)
  end

  def generate_canvas(site, config)
    background_image = if config.canvas.background_image
      File.read(File.join(site.config["source"], config.canvas.background_image))
    end

    JekyllOgImage::Element::Canvas.new(1200, 600,
      background_color: config.canvas.background_color,
      background_image: background_image
    )
  end

  def add_border_bottom(canvas, config)
    canvas.border(config.border_bottom.width,
      position: :bottom,
      fill: config.border_bottom.fill
    )
  end

  def add_image(canvas, image)
    canvas.image(image,
      gravity: :ne,
      width: 150,
      height: 150,
      radius: 50
    ) { |_canvas, _text| { x: 80, y: 100 } }
  end

  def add_header(canvas, post, config)
    canvas.text(post.data["title"],
      width: config.image ? 870 : 1040,
      color: config.header.color,
      dpi: 400,
      font: config.header.font_family
    ) { |_canvas, _text| { x: 80, y: 100 } }
  end

  def add_publish_date(canvas, post, config)
    date = post.date.strftime("%B %d, %Y")

    canvas.text(date,
      gravity: :sw,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: post.data["tags"].any? ? config.margin_bottom + 50 : config.margin_bottom } }
  end

  def add_tags(canvas, post, config)
    tags = post.data["tags"].map { |tag| "##{tag}" }.join(" ")

    canvas.text(tags,
      gravity: :sw,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: config.margin_bottom } }
  end

  def add_domain(canvas, post, config)
    canvas.text(config.domain,
      gravity: :se,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) do |_canvas, _text|
      {
        x: 80,
        y: post.data["tags"].any? ? config.margin_bottom + 50 : config.margin_bottom
      }
    end
  end
end
