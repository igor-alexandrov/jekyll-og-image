# frozen_string_literal: true

RSpec.describe JekyllOgImage do
  let(:config) do
    Jekyll.configuration(Jekyll::Utils.deep_merge_hashes(
      Jekyll::Configuration::DEFAULTS,
      {
        "source" => source_dir,
        "destination" => destination_dir,
        "plugins" => [ "jekyll-og-image" ]
      }
    ))
  end

  let(:site)     { Jekyll::Site.new(config) }
  let(:og_image) { JekyllOgImage::Generator.new(site.config) }

  before(:each) do
    site.read
  end

  after(:each) do
    FileUtils.rm_rf(File.join(source_dir, "assets"))
  end

  it "generates OpenGraph images for published posts" do
    og_image.generate(site)

    expect(Pathname.new(source_dir('assets', 'images', 'og', 'posts', 'a-week-with-the-apple-watch.png'))).to exist
    expect(Pathname.new(source_dir('assets', 'images', 'og', 'posts', 'advanced-markdown-tips.png'))).to exist
  end

  it "does not generate OpenGraph images for drafts" do
    og_image.generate(site)

    expect(Pathname.new(source_dir('assets', 'images', 'og', 'posts', 'what-is-jekyll.png'))).not_to exist
  end

  # --- Tests for content_types feature ---
  describe "when handling content_types" do
    let(:post_image_path) { Pathname.new(source_dir('assets', 'images', 'og', 'posts', 'a-week-with-the-apple-watch.png')) }
    let(:page_image_path) { Pathname.new(source_dir('assets', 'images', 'og', 'pages', 'about-us.png')) }
    let(:collection_image_path) { Pathname.new(source_dir('assets', 'images', 'og', 'my_collection', 'item1.png')) }

    context "with default configuration (no content_types specified)" do
      let(:site) { Jekyll::Site.new(config) }
      let(:og_image) { JekyllOgImage::Generator.new(site.config) }

      before { site.read; og_image.generate(site) }

      it "generates images only for posts" do
        expect(post_image_path).to exist
        expect(page_image_path).not_to exist
        expect(collection_image_path).not_to exist
      end

      it "places post images in the 'posts' subdirectory" do
        expect(post_image_path.dirname.basename.to_s).to eq("posts")
      end
    end

    context "when content_types specifies ['pages']" do
      let(:config_with_pages) do
        Jekyll.configuration(Jekyll::Utils.deep_merge_hashes(config, {
          "og_image" => { "content_types" => ["pages"] }
        }))
      end
      let(:site) { Jekyll::Site.new(config_with_pages) }
      let(:og_image) { JekyllOgImage::Generator.new(site.config) }

      before { site.read; og_image.generate(site) }

      it "generates images only for pages" do
        expect(post_image_path).not_to exist
        expect(page_image_path).to exist
        expect(collection_image_path).not_to exist
      end

      it "places page images in the 'pages' subdirectory" do
        expect(page_image_path.dirname.basename.to_s).to eq("pages")
      end
    end

    context "when content_types specifies ['my_collection']" do
      let(:config_with_collection) do
        Jekyll.configuration(Jekyll::Utils.deep_merge_hashes(config, {
          "og_image" => { "content_types" => ["my_collection"] }
        }))
      end
      let(:site) { Jekyll::Site.new(config_with_collection) }
      let(:og_image) { JekyllOgImage::Generator.new(site.config) }

      before { site.read; og_image.generate(site) }

      it "generates images only for the specified collection" do
        expect(post_image_path).not_to exist
        expect(page_image_path).not_to exist
        expect(collection_image_path).to exist
      end

      it "places collection images in the 'my_collection' subdirectory" do
        expect(collection_image_path.dirname.basename.to_s).to eq("my_collection")
      end

      it "handles collection items without tags gracefully" do
        expect(collection_image_path).to exist
      end
    end

    context "when content_types specifies ['posts', 'pages']" do
      let(:config_with_multiple) do
        Jekyll.configuration(Jekyll::Utils.deep_merge_hashes(config, {
          "og_image" => { "content_types" => ["posts", "pages"] }
        }))
      end
      let(:site) { Jekyll::Site.new(config_with_multiple) }
      let(:og_image) { JekyllOgImage::Generator.new(site.config) }

      before { site.read; og_image.generate(site) }

      it "generates images for both posts and pages" do
        expect(post_image_path).to exist
        expect(page_image_path).to exist
        expect(collection_image_path).not_to exist
      end
    end

    context "with front matter overrides on a page" do
      let(:config_with_pages) do
        Jekyll.configuration(Jekyll::Utils.deep_merge_hashes(config, {
          "og_image" => { "content_types" => ["pages"] }
        }))
      end
      let(:site) { Jekyll::Site.new(config_with_pages) }
      let(:og_image) { JekyllOgImage::Generator.new(site.config) }
      let(:overridden_domain) { "overridden.example.com" }

      before do
        site.read
        about_page = site.pages.find { |p| p.name == 'about.md' }
        about_page.data['og_image'] = { 'domain' => overridden_domain }
        og_image.generate(site)
      end

      it "applies front matter overrides during generation" do
        expect(page_image_path).to exist
      end
    end
  end
end
