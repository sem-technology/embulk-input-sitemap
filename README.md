# Sitemap input plugin for Embulk

Embulk input plugin for sitemap.xml.

## Overview

* **Plugin type**: input
* **Resume supported**: no
* **Cleanup supported**: no
* **Guess supported**: no

## Configuration

- **url**: The sitemap url (string, required)
- **params**: Query parameter for sitemap url (array, default: [])

## Example

```yaml
in:
  type: sitemap
  url: https://sem-technology.info/sitemap.xml
  params:
    - {name: page, value: 1}
```


## Build

```
$ rake
```
