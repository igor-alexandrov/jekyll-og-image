# Jekyll OG Image

A Jekyll plugin to automatically generate open graph images for posts.

[![Gem Version](https://badge.fury.io/rb/jekyll-og-image.svg)](https://badge.fury.io/rb/jekyll-og-image)
[![Lint](https://github.com/igor-alexandrov/jekyll-og-image/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/igor-alexandrov/jekyll-og-image/actions/workflows/lint.yml)
[![Specs](https://github.com/igor-alexandrov/jekyll-og-image/actions/workflows/specs.yml/badge.svg?branch=main)](https://github.com/igor-alexandrov/jekyll-og-image/actions/workflows/specs.yml)

## Installation

Add this line to your site's Gemfile:

```ruby
  gem 'jekyll-feed'
```

And then add this line to your site's `_config.yml`:

```yaml
plugins:
  - jekyll-seo-tag
  - jekyll-og-image
```

## Usage

Jekyll OG Image works together with [jekyll-seo-tag](https://github.com/jekyll/jekyll-seo-tag) plugin. It automatically generates open graph images for posts and inserts them into the posts metadata.

## Examples

Configuration can be defined on the site level or on the post level.

For a side wide level configuration, edit your `_config.yml`, for a post level configuration, edit the post's front matter.

### Single Color

```yaml
# _config.yml
og_image:
  output_dir: "assets/images/og"
  domain: "igor.works"
  border_bottom:
    width: 20
    fill:
      - "#4285F4"
```

![Example 2](examples/2.png)

### Multiple Colors

```yaml
# _config.yml
og_image:
  output_dir: "assets/images/og"
  image: "/assets/images/igor.jpeg"
  domain: "igor.works"
  border_bottom:
    width: 20
    fill:
      - "#820C02"
      - "#A91401"
      - "#D51F06"
      - "#DE3F24"
      - "#EDA895"
```

![Example 1](examples/1.png)

### Background Color and Text Color

```yaml
# _config.yml
og_image:
  output_dir: "/assets/og"
  image: "/assets/images/igor.jpeg"
  canvas:
    background_color: "#F9E065"
  header:
    font_family: "Roboto, Bold"
    color: "#333333"
  content:
    font_family: "Roboto, Regular"
    color: "#333333"
  force: false
  domain: "igor.works"
  border_bottom:
    width: 50
    fill:
      - "#002B7F"
      - "#FCD116"
      - "#CE1126"
```

![Example 3](examples/3.png)

### Background Image

```yaml
# _config.yml
og_image:
  output_dir: "/assets/og"
  image: "/assets/images/igor.jpeg"
  header:
    font_family: "Roboto, Bold"
    color: "#333333"
  content:
    font_family: "Roboto, Bold"
    color: "#333333"
  force: false
  domain: "igor.works"

# _posts/2024-02-15-traefik-tunning-for-rails-applications-part-1.md
---
title: Traefik Tuning for Rails Applications (part 1)
layout: post
tags:
  - Rails
  - Traefik
  - Kamal
og_image:
  canvas:
    background_image: "/assets/images/bc_3.jpg"
```

![Example 4](examples/4.png)


## Contributing

* Fork it (https://github.com/igor-alexandrov/jekyll-og-image)
* Create your feature branch (`git checkout -b my-new-feature`)
* Commit your changes (`git commit -am 'Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
