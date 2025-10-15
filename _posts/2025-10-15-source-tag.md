---
layout: post
title: "Source Tag"
date: 2025-10-15
categories: [web-development, html, coding-practices]
post_description: "This article delves into the concept of 'Source Tag', shedding light on its function, implementation in various coding platforms and its crucial role in enhancing search engine optimization for technical blog posts."
---

![Image](/assets/g4f94f4a1ead4ee5d42d1a4e194bb52ee0714519896bb7e543ab39b6c2e51ee46eddf6b003bbf2aacaa4a7395e114d068004fc514672572bdd5d223ce78e0501b_1280.jpg){: .img-fluid style="max-height:720px; height:auto;" }

## Source Tag

The `source` tag, an integral part of modern web development, provides multiple media resources for media elements like `<video>` and `<picture>`. It is immensely useful for developers working with responsive or adaptive designs, where different resources may be needed depending upon device characteristics. 

Drupal, a popular content management framework for building web applications, effectively makes use of the `source` tag to manage multiple media resources. For instance, when building a responsive design, you might want to serve higher resolution images to devices with larger screens, while serving smaller images to devices with less powerful processing capabilities. This can be easily achieved in Drupal by using the `source` tag.

Here's a simple example:
```html
<picture>
  <source media="(max-width: 799px)" srcset="elva-480w.jpg">
  <source media="(min-width: 800px)" srcset="elva-800w.jpg">
  <img src="elva-800w.jpg" alt="Chris standing up holding his daughter Elva">
</picture>
```
In this snippet, we've used two `source` tags within the `picture` element to specify different images for different screen sizes. If the viewing device has a screen width less than 800 pixels, then `elva-480w.jpg` is presented. For devices with a screen width of 800 pixels or more, `elva-800w.jpg` is shown. The `img` tag is kept as the default image source that is displayed when no other sources are matched or if the browser does not support the `picture` element.

Drupal provides the `twig` templating engine, which can be used to set `source` tags dynamically. For example:
```php
<picture>
  <source media="(max-width: 799px)" srcset="{{fields['elva_480w'].content}}">
  <source media="(min-width: 800px)" srcset="{{fields['elva_800w'].content}}">
  <img src="{{fields['elva_800w'].content}}" alt="{{fields['caption'].content}}">
</picture>
```
The above sample uses Drupal's `twig` templates to dynamically fill in the `srcset` attribute values.

Managing various media resources efficiently can be challenging at times, especially with the rise in the diversity of devices and screen sizes. This is where effective use of the `source` tag can significantly contribute to site performance optimization in Drupal development and design. Incorporating the `source` tag into your project management strategies would certainly be a wise decision in the rapidly-evolving web development landscape.
