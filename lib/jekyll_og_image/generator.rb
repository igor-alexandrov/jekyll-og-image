# frozen_string_literal: true

class JekyllOgImage::Generator < Jekyll::Generator
  safe true

  def generate(site)
    config = JekyllOgImage.config

    config.collections.each do |type|
      process_collection(site, type, config)
    end
  end

  private

  def process_collection(site, type, config)
    Jekyll.logger.info "Jekyll Og Image:", "Processing type: #{type}" if config.verbose?

    items = get_items_for_collection(site, type)
    return if items.empty?

    base_output_dir = File.join(config.output_dir, type)
    absolute_output_dir = File.join(site.config["source"], base_output_dir)
    FileUtils.mkdir_p absolute_output_dir

    items.each do |item|
      if item.respond_to?(:draft?) && item.draft? && config.skip_drafts?
        Jekyll.logger.info "Jekyll Og Image:", "Skipping draft: #{item.data['title']}" if config.verbose?
        next
      end

      fallback_basename = if item.respond_to?(:basename_without_ext)
                            item.basename_without_ext
                            # rubocop:disable Layout/ElseAlignment # Disabled due to RuboCop error in v3.3.0
                          else
                            # rubocop:enable Layout/ElseAlignment
                            File.basename(item.name, File.extname(item.name))
      end

      slug = item.data["slug"] || Jekyll::Utils.slugify(item.data["title"] || fallback_basename)
      image_filename = "#{slug}.png"
      absolute_image_path = File.join(absolute_output_dir, image_filename)
      relative_image_path = File.join("/", base_output_dir, image_filename) # Use leading slash for URL

      if !File.exist?(absolute_image_path) || config.force?
        Jekyll.logger.info "Jekyll Og Image:", "Generating image #{absolute_image_path}" if config.verbose?
        generate_image_for_document(site, item, absolute_image_path, config)
      else
        Jekyll.logger.info "Jekyll Og Image:", "Skipping image generation for #{relative_image_path} as it already exists." if config.verbose?
      end

      item.data["image"] ||= {
        "path" => relative_image_path,
        "width" => JekyllOgImage.config.canvas.width,
        "height" => JekyllOgImage.config.canvas.height,
        "alt" => item.data["title"]
      }
    end
  end

  def get_items_for_collection(site, type)
    case type
    when "posts"
      site.posts.docs
    when "pages"
      site.pages.reject { |page| !page.html? }
    else
      if site.collections.key?(type)
        site.collections[type].docs
      else
        Jekyll.logger.warn "Jekyll Og Image:", "Unknown collection type \"#{type}\" configured. Skipping."
        []
      end
    end
  end

  def generate_image_for_document(site, item, path, base_config)
    config = base_config.merge!(item.data["og_image"] || {})

    return unless config.enabled?

    canvas = generate_canvas(site, config)
    canvas = add_border_bottom(canvas, config) if config.border_bottom
    canvas = add_image(canvas, File.read(File.join(site.config["source"], config.image))) if config.image
    canvas = add_header(canvas, item, config)
    canvas = add_publish_date(canvas, item, config)
    canvas = add_tags(canvas, item, config) if item.data["tags"]&.any?
    canvas = add_domain(canvas, item, config) if config.domain

    canvas.save(path)
  end

  def generate_canvas(site, config)
    background_image = if config.canvas.background_image
      bg_path = File.join(site.config["source"], config.canvas.background_image.gsub(/^\//, ""))
      File.exist?(bg_path) ? File.read(bg_path) : nil
    end

    JekyllOgImage::Element::Canvas.new(JekyllOgImage.config.canvas.width, JekyllOgImage.config.canvas.height,
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

  def add_header(canvas, item, config)
    title = item.data["title"] || "Untitled"
    canvas.text(title,
      width: config.image ? 870 : 1040,
      color: config.header.color,
      dpi: 400,
      font: config.header.font_family
    ) { |_canvas, _text| { x: 80, y: 100 } }
  end

  def add_publish_date(canvas, item, config)
    return canvas unless item.respond_to?(:date) && item.date

    date = item.date.strftime("%B %d, %Y")
    y_pos = (item.data["tags"]&.any? ? config.margin_bottom + 50 : config.margin_bottom)

    canvas.text(date,
      gravity: :sw,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: y_pos } }
  end

  def add_tags(canvas, item, config)
    tags_list = item.data["tags"]
    return canvas unless tags_list.is_a?(Array) && tags_list.any?

    tags = tags_list.map { |tag| "##{tag}" }.join(" ")

    canvas.text(tags,
      gravity: :sw,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: config.margin_bottom } }
  end

  def add_domain(canvas, item, config)
    y_pos = if item.data["tags"]&.any?
              config.margin_bottom + 50
              # rubocop:disable Layout/ElseAlignment # Disabled due to RuboCop error in v3.3.0
            else
              # rubocop:enable Layout/ElseAlignment
              config.margin_bottom
    end

    canvas.text(config.domain,
      gravity: :se,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: y_pos } }
  end
end
