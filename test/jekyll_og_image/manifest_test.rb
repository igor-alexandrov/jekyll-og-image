# frozen_string_literal: true

require "test_helper"

class JekyllOgImage::ManifestTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @path = File.join(@dir, JekyllOgImage::Manifest::FILENAME)
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def test_fresh_only_for_recorded_digest
    manifest = JekyllOgImage::Manifest.new(@dir)
    manifest.record("posts/a.png", "abc")

    assert manifest.fresh?("posts/a.png", "abc")
    refute manifest.fresh?("posts/a.png", "def")
    refute manifest.fresh?("posts/b.png", "abc")
  end

  def test_persists_between_instances
    manifest = JekyllOgImage::Manifest.new(@dir)
    manifest.record("posts/a.png", "abc")
    manifest.save

    assert JekyllOgImage::Manifest.new(@dir).fresh?("posts/a.png", "abc")
  end

  def test_save_drops_entries_not_recorded_since_loading
    File.write(@path, JSON.generate("posts/a.png" => "abc", "posts/deleted.png" => "def"))

    manifest = JekyllOgImage::Manifest.new(@dir)
    manifest.record("posts/a.png", "abc")
    manifest.save

    assert_equal({ "posts/a.png" => "abc" }, JSON.parse(File.read(@path)))
  end

  def test_save_does_not_rewrite_unchanged_file
    File.write(@path, JSON.pretty_generate("posts/a.png" => "abc"))
    File.utime(Time.at(0), Time.at(0), @path)

    manifest = JekyllOgImage::Manifest.new(@dir)
    manifest.record("posts/a.png", "abc")
    manifest.save

    assert_equal Time.at(0), File.mtime(@path)
  end

  def test_treats_unreadable_manifest_as_empty
    File.write(@path, "not json")

    refute JekyllOgImage::Manifest.new(@dir).fresh?("posts/a.png", "abc")
  end
end
