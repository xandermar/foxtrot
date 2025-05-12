---
layout: default-no-post-list
title: Articles
permalink: /articles
nav_order: 4.1
---

<h1>All Articles</h1>

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
      <small>({{ post.date | date: "%B %d, %Y" }})</small>
    </li>
  {% endfor %}
</ul>
<div class="mt-3">See <a href="/categories">Post Categories</a></div>
