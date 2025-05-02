---
layout: default
title: Post Categories
permalink: /categories
nav_order: 10
---

<h1>All Categories</h1>

<ul>
  {% assign categories = site.categories | sort %}
  {% for category in categories %}
    {% assign category_name = category[0] %}
    <li>
      <a href="{{ '/category/' | append: category_name | append: '/' | relative_url }}">
        {{ category_name }} ({{ category[1].size }})
      </a>
    </li>
  {% endfor %}
</ul>
