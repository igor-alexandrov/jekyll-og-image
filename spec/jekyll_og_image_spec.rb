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
end
