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

### Single Color

```yaml
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



## Contributing

* Fork it (https://github.com/igor-alexandrov/jekyll-og-image)
* Create your feature branch (`git checkout -b my-new-feature`)
* Commit your changes (`git commit -am 'Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).