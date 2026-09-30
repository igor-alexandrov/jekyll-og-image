# frozen_string_literal: true

require "digest"

class JekyllOgImage::Generator < Jekyll::Generator
  safe true

  def generate(site)
    config = JekyllOgImage.config
    @missing_files = Set.new
    @file_digests = {}
    manifest = JekyllOgImage::Manifest.new(File.join(site.source, config.output_dir))

    # `jekyll serve` reuses this generator for every rebuild. Forcing only the first
    # build stops rewritten images from triggering the watcher in an endless loop.
    @force = config.force? && !@forced
    @forced = true

    config.collections.each do |type|
      process_collection(site, type, config, manifest)
    end

    manifest.save
  end

  private

  def process_collection(site, type, config, manifest)
    Jekyll.logger.info "Jekyll Og Image:", "Processing type: #{type}" if config.verbose?

    get_items_for_collection(site, type).each do |item|
      if item.respond_to?(:draft?) && item.draft? && config.skip_drafts?
        Jekyll.logger.info "Jekyll Og Image:", "Skipping draft: #{item.data['title']}" if config.verbose?
        next
      end

      item_config = config.merge(item.data["og_image"] || {})
      next unless item_config.enabled?

      image_path = File.join(type, "#{image_basename(item)}.png")
      site_image_path = File.join(config.output_dir, image_path)
      absolute_image_path = File.join(site.source, site_image_path)
      digest = image_digest(site, item, item_config)

      if @force || !File.exist?(absolute_image_path) || !manifest.fresh?(image_path, digest)
        Jekyll.logger.info "Jekyll Og Image:", "Generating image #{absolute_image_path}" if config.verbose?
        FileUtils.mkdir_p(File.dirname(absolute_image_path))
        generate_image_for_document(site, item, absolute_image_path, item_config)
      else
        Jekyll.logger.info "Jekyll Og Image:", "Skipping #{site_image_path}, it is up to date" if config.verbose?
      end

      next unless File.exist?(absolute_image_path)

      manifest.record(image_path, digest)
      register_static_file(site, site_image_path, config)

      item.data["image"] ||= {
        "path" => File.join("/", site_image_path), # Use leading slash for URL
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
      site.pages.select(&:html?)
    else
      if site.collections.key?(type)
        site.collections[type].docs
      else
        Jekyll.logger.warn "Jekyll Og Image:", "Unknown collection type \"#{type}\" configured. Skipping."
        []
      end
    end
  end

  # The source file's path without its collection directory and extension, which is
  # unique within the site: "_posts/2024-01-01-hello.md" => "2024-01-01-hello",
  # "blog/index.md" => "blog/index".
  def image_basename(item)
    path = item.relative_path.delete_prefix("/")
    path = path.delete_prefix("#{item.collection.relative_directory}/") if item.respond_to?(:collection) && item.collection
    path = path.delete_suffix(File.extname(path))

    path.split("/").map { |segment| slugify_path_segment(segment) }.join("/")
  end

  def slugify_path_segment(segment)
    slug = Jekyll::Utils.slugify(segment)
    # A name made only of characters slugify removes, e.g. emoji
    slug.empty? ? Digest::SHA256.hexdigest(segment)[0, 12] : slug
  end

  # Changes whenever anything that affects the rendered image changes
  def image_digest(site, item, config)
    inputs = [
      JekyllOgImage::VERSION,
      JekyllOgImage.config.canvas.to_h.slice(:width, :height),
      config.canvas.to_h,
      config.header.to_h,
      config.content.to_h,
      config.image.to_h,
      config.border_bottom&.to_h,
      config.metadata.to_h,
      config.domain,
      item.data["title"],
      config.metadata.fields.map { |field| metadata_value_for(item, field, config) },
      file_digest(site, config.image.path),
      file_digest(site, config.canvas.background_image)
    ]

    Digest::SHA256.hexdigest(JSON.generate(inputs))
  end

  def file_digest(site, path)
    return unless path

    absolute_path = File.join(site.source, path)
    @file_digests[absolute_path] ||= Digest::SHA256.file(absolute_path).hexdigest if File.file?(absolute_path)
  end

  def register_static_file(site, site_image_path, config)
    relative_path = File.join("/", site_image_path)
    return if site.static_files.any? { |file| file.relative_path == relative_path }

    # Leading slash in dir, as Jekyll's reader does, so relative_path matches the check above
    static_file = Jekyll::StaticFile.new(
      site,
      site.source,
      File.dirname(relative_path),
      File.basename(relative_path)
    )

    site.static_files << static_file
    Jekyll.logger.info "Jekyll Og Image:", "Added #{site_image_path} to static files" if config.verbose?
  end

  def generate_image_for_document(site, item, path, config)
    canvas = generate_canvas(site, config)
    canvas = add_border_bottom(canvas, config) if config.border_bottom
    logo = read_source_file(site, config.image.path, "og_image.image.path") if config.image.path
    canvas = add_image(canvas, logo, config) if logo
    canvas = add_header(canvas, item, config)
    canvas = add_metadata(canvas, item, config)
    canvas = add_domain(canvas, item, config) if config.domain

    canvas.save(path)
  end

  def generate_canvas(site, config)
    if config.canvas.background_image
      background_image = read_source_file(site, config.canvas.background_image, "og_image.canvas.background_image")
    end

    JekyllOgImage::Element::Canvas.new(JekyllOgImage.config.canvas.width, JekyllOgImage.config.canvas.height,
      background_color: config.canvas.background_color,
      background_image: background_image
    )
  end

  def read_source_file(site, path, option)
    absolute_path = File.join(site.source, path)
    return File.binread(absolute_path) if File.file?(absolute_path)

    # Warn once per build, not once per document
    Jekyll.logger.warn "Jekyll Og Image:", "#{option} file not found: #{path}, skipping it" if @missing_files.add?(path)
    nil
  end

  def add_border_bottom(canvas, config)
    canvas.border(config.border_bottom.width,
      position: :bottom,
      fill: config.border_bottom.fill
    )
  end

  def add_image(canvas, image_data, config)
    image_config = config.image
    canvas.image(image_data,
      gravity: image_config.gravity,
      width: image_config.width,
      height: image_config.height,
      radius: image_config.radius
    ) { |_canvas, _text| { x: image_config.position[:x], y: image_config.position[:y] } }
  end

  def add_header(canvas, item, config)
    title = item.data["title"] || "Untitled"
    full_title = "#{config.header.prefix}#{title}#{config.header.suffix}"

    # Calculate available width for header text to avoid overlap with image
    header_width = if config.image.path
      # Canvas width - left margin - right margin - image width - spacing
      # 1200 - 80 - 80 - image_width - 30 (spacing)
      1040 - config.image.width - 30
    else
      1040
    end

    canvas.text(full_title,
      width: header_width,
      color: config.header.color,
      dpi: 400,
      font: config.header.font_family
    ) { |_canvas, _text| { x: 80, y: 100 } }
  end

  def add_metadata(canvas, item, config)
    metadata_text = metadata_text_for(item, config)
    return canvas if metadata_text.empty?

    metadata_width = metadata_width_for(config)

    canvas.text(metadata_text,
      gravity: :sw,
      width: metadata_width,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: config.margin_bottom } }
  end

  def metadata_text_for(item, config)
    metadata_parts = []
    metadata_width = metadata_width_for(config)

    config.metadata.fields.each do |field|
      metadata_value = metadata_value_for(item, field, config)
      next if metadata_value.nil? || metadata_value.empty?

      if field == "description"
        candidate_text = (metadata_parts + [ metadata_value ]).join(config.metadata.separator)
        next unless metadata_text_fits_single_line?(candidate_text, metadata_width, config)
      end

      metadata_parts << metadata_value
    end

    metadata_parts.join(config.metadata.separator)
  end

  def metadata_value_for(item, field, config)
    case field
    when "date"
      item.respond_to?(:date) && item.date ? item.date.strftime(config.metadata.date_format) : nil
    when "tags"
      return nil unless item.data["tags"].is_a?(Array) && item.data["tags"].any?

      item.data["tags"].map { |tag| "##{tag}" }.join(" ")
    else
      # Support custom fields from front matter
      item.data[field]&.to_s
    end
  end

  def metadata_width_for(config)
    config.domain ? 600 : 1040
  end

  def metadata_text_fits_single_line?(text, metadata_width, config)
    options = {
      width: metadata_width,
      dpi: 150,
      font: config.content.font_family,
      align: :low
    }
    options[:wrap] = :word if Vips.at_least_libvips?(8, 14)

    single_line_height = Vips::Image.text("Ay", **options).height
    rendered_height = Vips::Image.text(JekyllOgImage::Element::Text.escape_markup(text), **options).height

    rendered_height <= (single_line_height * 1.6)
  end


  def add_domain(canvas, _item, config)
    y_pos = config.margin_bottom

    canvas.text(config.domain,
      gravity: :se,
      color: config.content.color,
      dpi: 150,
      font: config.content.font_family
    ) { |_canvas, _text| { x: 80, y: y_pos } }
  end
end
