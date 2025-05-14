# frozen_string_literal: true

RSpec.describe JekyllOgImage::Configuration do
  subject { described_class.new(raw_config) }

  let(:raw_config) { Hash.new }

  describe '#merge!' do
    let(:raw_config) { { "output_dir" => "foo" } }
    let(:other) { described_class.new({ "output_dir" => "bar" }) }

    it 'returns a new Configuration object with the merged values' do
      expect(subject.merge!(other)).to eq(described_class.new({ "output_dir" => "bar" }))
    end

    context 'when other is not a Configuration object' do
      let(:other) { { "output_dir" => "bar" } }

      it 'returns a new Configuration object with the merged values' do
        expect(subject.merge!(other)).to eq(described_class.new({ "output_dir" => "bar" }))
      end
    end
  end

  describe '#output_dir' do
    context 'when output_dir is not set' do
      it 'returns "assets/images/og"' do
        expect(subject.output_dir).to eq("assets/images/og")
      end
    end

    context 'when output_dir is set' do
      let(:raw_config) { { "output_dir" => "foo" } }

      it 'returns "foo"' do
        expect(subject.output_dir).to eq("foo")
      end
    end
  end

  describe '#force?' do
    context 'when force is not set' do
      it 'returns false' do
        expect(subject.force?).to be(false)
      end
    end

    context 'when force is set' do
      let(:raw_config) { { "force" => true } }

      it 'returns true' do
        expect(subject.force?).to be(true)
      end
    end
  end

  describe '#verbose?' do
    context 'when verbose is not set' do
      it 'returns false' do
        expect(subject.verbose?).to be(false)
      end
    end

    context 'when verbose is set' do
      let(:raw_config) { { "verbose" => true } }

      it 'returns true' do
        expect(subject.verbose?).to be(true)
      end
    end
  end

  describe '#skip_drafts?' do
    context 'when skip_drafts is not set' do
      it 'returns true' do
        expect(subject.skip_drafts?).to be(true)
      end
    end

    context 'when skip_drafts is set' do
      let(:raw_config) { { "skip_drafts" => false } }

      it 'returns false' do
        expect(subject.skip_drafts?).to be(false)
      end
    end
  end

  describe '#canvas' do
    context 'when canvas is not set' do
      it 'returns a Canvas object with default values' do
        expect(subject.canvas).to eq(JekyllOgImage::Configuration::Canvas.new)
        expect(subject.canvas.background_color).to eq("#FFFFFF")
        expect(subject.canvas.background_image).to be_nil
        expect(subject.canvas.width).to eq(1200)
        expect(subject.canvas.height).to eq(600)
      end
    end

    context 'when canvas is set' do
      let(:raw_config) { { "canvas" => { "background_color" => "#000000", "background_image" => "foo.png", "width" => 800, "height" => 400 } } }

      it 'returns a Canvas object with the given values' do
        expect(subject.canvas).to eq(JekyllOgImage::Configuration::Canvas.new(
          background_color: "#000000",
          background_image: "foo.png",
          width: 800,
          height: 400
        ))
      end
    end

    context 'when only width is set' do
      let(:raw_config) { { "canvas" => { "width" => 800 } } }

      it 'returns a Canvas object with the custom width and default height' do
        expect(subject.canvas.width).to eq(800)
        expect(subject.canvas.height).to eq(600)
      end
    end

    context 'when only height is set' do
      let(:raw_config) { { "canvas" => { "height" => 400 } } }

      it 'returns a Canvas object with the custom height and default width' do
        expect(subject.canvas.width).to eq(1200)
        expect(subject.canvas.height).to eq(400)
      end
    end
  end

  describe '#header' do
    context 'when header is not set' do
      it 'returns a Header object with default values' do
        expect(subject.header).to eq(JekyllOgImage::Configuration::Header.new)
        expect(subject.header.font_family).to eq("Helvetica, Bold")
        expect(subject.header.color).to eq("#2f313d")
      end
    end

    context 'when header is set' do
      let(:raw_config) { { "header" => { "font_family" => "Arial", "color" => "#000000" } } }

      it 'returns a Header object with the given values' do
        expect(subject.header).to eq(JekyllOgImage::Configuration::Header.new(font_family: "Arial", color: "#000000"))
      end
    end
  end

  describe '#content' do
    context 'when content is not set' do
      it 'returns a Content object with default values' do
        expect(subject.content).to eq(JekyllOgImage::Configuration::Content.new)
        expect(subject.content.font_family).to eq("Helvetica, Regular")
        expect(subject.content.color).to eq("#535358")
      end

      context 'when content is set' do
        let(:raw_config) { { "content" => { "font_family" => "Arial", "color" => "#000000" } } }

        it 'returns a Content object with the given values' do
          expect(subject.content).to eq(JekyllOgImage::Configuration::Content.new(font_family: "Arial", color: "#000000"))
        end
      end
    end
  end

  describe '#border_bottom' do
    context 'when border_bottom is not set' do
      it 'returns nil' do
        expect(subject.border_bottom).to be_nil
      end
    end

    context 'when border_bottom is set' do
      let(:raw_config) { { "border_bottom" => { "width" => 10, "fill" => "#000000" } } }

      it 'returns a Border object with the given values' do
        expect(subject.border_bottom).to eq(JekyllOgImage::Configuration::Border.new(width: 10, fill: "#000000"))
      end
    end
  end

  describe '#margin_bottom' do
    context 'when border_bottom is not set' do
      it 'returns 80' do
        expect(subject.margin_bottom).to eq(80)
      end
    end

    context 'when border_bottom is set' do
      let(:raw_config) { { "border_bottom" => { "width" => 10 } } }

      it 'returns 90' do
        expect(subject.margin_bottom).to eq(90)
      end
    end
  end

  describe '#image' do
    context 'when image is not set' do
      it 'returns nil' do
        expect(subject.image).to be_nil
      end
    end

    context 'when image is set' do
      let(:raw_config) { { "image" => "foo.png" } }

      it 'returns "foo.png"' do
        expect(subject.image).to eq("foo.png")
      end
    end
  end

  describe '#domain' do
    context 'when domain is not set' do
      it 'returns nil' do
        expect(subject.domain).to be_nil
      end
    end

    context 'when domain is set' do
      let(:raw_config) { { "domain" => "foo.com" } }

      it 'returns "foo.com"' do
        expect(subject.domain).to eq("foo.com")
      end
    end
  end
end
