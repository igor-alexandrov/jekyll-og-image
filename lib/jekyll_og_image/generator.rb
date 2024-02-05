# frozen_string_literal: true

class JekyllOgImage::Generator < Jekyll::Generator
  safe true

  def generate(site)
    base_path = File.join(
      JekyllOgImage.config.output_dir,
      "posts"
    )

    FileUtils.mkdir_p File.join(site.config["source"], base_path)

    site.posts.docs.each do |post|
      path = File.join(site.config["source"], base_path, "#{post.data['slug']}.png")

      if !File.exist?(path) || JekyllOgImage.config.force?
        Jekyll.logger.info "Jekyll Og Image:", "Generating image #{path}"
        generate_image_for_post(site, post, path)
      else
        Jekyll.logger.info "Jekyll Og Image:", "Skipping image generation #{path} as it already exists."
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
    date = post.date.strftime("%B %d, %Y")

    image = JekyllOgImage::Element::Image.new(1200, 600)
      .border(JekyllOgImage.config.border_bottom["width"],
        position: :bottom,
        fill: JekyllOgImage.config.border_bottom["fill"]
      )
      .text(post.data["title"], width: 1040, color: "#2f313d", dpi: 500, font: "Helvetica, Bold") do |_canvas, _text|
        {
          x: 80,
          y: 100
        }
      end
      .text(date, gravity: :sw, color: "#535358", dpi: 150, font: "Helvetica, Regular") do |_canvas, _text|
        {
          x: 80,
          y: post.data["tags"].any? ? 150 : 100
        }
      end

    if post.data["tags"].any?
      tags = post.data["tags"].map { |tag| "##{tag}" }.join(" ")

      image = image.text(tags, gravity: :sw, color: "#535358", dpi: 150, font: "Helvetica, Regular") do |_canvas, _text|
        {
          x: 80,
          y: 100
        }
      end
    end

    if JekyllOgImage.config.domain
      image = image.text(JekyllOgImage.config.domain, gravity: :se, color: "#535358", dpi: 150, font: "Helvetica, Regular") do |_canvas, _text|
        {
          x: 80,
          y: post.data["tags"].any? ? 150 : 100
        }
      end
    end

    image.save(path)
  end
end
