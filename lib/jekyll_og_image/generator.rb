# frozen_string_literal: true

class JekyllOgImage::Generator < Jekyll::Generator
  safe true

  def generate(site)
    config = JekyllOgImage.config

    config.content_types.each do |type|
      process_content_type(site, type, config)
    end
  end

  private

  def process_content_type(site, type, config)
    Jekyll.logger.info "Jekyll Og Image:", "Processing type: #{type}" if config.verbose?

    documents = get_documents_for_type(site, type)
    return if documents.empty?

    base_output_dir = File.join(config.output_dir, type)
    absolute_output_dir = File.join(site.config["source"], base_output_dir)
    FileUtils.mkdir_p absolute_output_dir

    documents.each do |doc|
      if doc.respond_to?(:draft?) && doc.draft? && config.skip_drafts?
        Jekyll.logger.info "Jekyll Og Image:", "Skipping draft: #{doc.data['title']}" if config.verbose?
        next
      end

      fallback_basename = if doc.respond_to?(:basename_without_ext)
                          doc.basename_without_ext
                        else
                          File.basename(doc.name, File.extname(doc.name))
                        end
      slug = doc.data['slug'] || Jekyll::Utils.slugify(doc.data['title'] || fallback_basename)
      image_filename = "#{slug}.png"
      absolute_image_path = File.join(absolute_output_dir, image_filename)
      relative_image_path = File.join("/", base_output_dir, image_filename) # Use leading slash for URL

      if !File.exist?(absolute_image_path) || config.force?
        Jekyll.logger.info "Jekyll Og Image:", "Generating image #{absolute_image_path}" if config.verbose?
        generate_image_for_document(site, doc, absolute_image_path, config)
      else
        Jekyll.logger.info "Jekyll Og Image:", "Skipping image generation for #{relative_image_path} as it already exists." if config.verbose?
      end

      doc.data["image"] ||= {
        "path" => relative_image_path,
        "width" => 1200,
        "height" => 600,
        "alt" => doc.data["title"] 
      }
    end
  end

  def get_documents_for_type(site, type)
    case type
    when "posts"
      site.posts.docs
    when "pages"
      site.pages.reject { |page| !page.html? }
    else
      if site.collections.key?(type)
        site.collections[type].docs
      else
        Jekyll.logger.warn "Jekyll Og Image:", "Unknown content type '#{type}' configured. Skipping."
        []
      end
    end
  end

  def generate_image_for_document(site, doc, path, base_config)
    config = base_config.merge!(doc.data["og_image"] || {})

    canvas = generate_canvas(site, config)
    canvas = add_border_bottom(canvas, config) if config.border_bottom
    canvas = add_image(canvas, File.read(File.join(site.config["source"], config.image))) if config.image
    canvas = add_header(canvas, doc, config)
    canvas = add_publish_date(canvas, doc, config)
    canvas = add_tags(canvas, doc, config) if doc.data["tags"]&.any? 
    canvas = add_domain(canvas, doc, config) if config.domain

    canvas.save(path)
  end

  def generate_canvas(site, config)
    background_image = if config.canvas.background_image
      bg_path = File.join(site.config["source"], config.canvas.background_image.gsub(/^\//, ''))
      File.exist?(bg_path) ? File.read(bg_path) : nil
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

  def add_header(canvas, doc, config)
    title = doc.data["title"] || "Untitled"
    canvas.text(title,
      width: config.image ? 870 : 1040,
      color: config.header.color,
      dpi: 400,
      font: config.header.font_family
    ) { |_canvas, _text| { x: 80, y: 100 } }
  end

  def add_publish_date(canvas, doc, config)
    return canvas unless doc.respond_to?(:date) && doc.date

    date = doc.date.strftime("%B %d, %Y")
    y_pos = (doc.data["tags"]&.any? ? config.margin_bottom + 50 : config.margin_bottom)

    canvas.text(date,
      gravity: :sw,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: y_pos } }
  end

  def add_tags(canvas, doc, config)
    tags_list = doc.data["tags"]
    return canvas unless tags_list.is_a?(Array) && tags_list.any?

    tags = tags_list.map { |tag| "##{tag}" }.join(" ")

    canvas.text(tags,
      gravity: :sw,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: config.margin_bottom } }
  end

  def add_domain(canvas, doc, config)
    y_pos = if doc.data["tags"]&.any?
              config.margin_bottom + 50
            else
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
