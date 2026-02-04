---
layout: default-no-post-list
title: Articles
permalink: /articles
nav_order: 4.1
---

<img src="/assets/articles.jpg" alt="Xandermar LLC hero banner showing a modern workspace with a sleek digital design theme, conveying a confident and professional tone" width="1200" height="500" style="width:100%;height:350px;object-fit:cover;display:block;" loading="lazy" decoding="async" />

<h1>All Articles</h1>

<div class="row">
{% for post in site.posts %}
<div class="card m-1 bg-light mx-auto" style="width: 18rem;">
  <div class="card-body">
    <h5 class="card-title"><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h5>
    <p class="card-text"><small>Posted: ({{ post.date | date: "%B %d, %Y" }})</small></p>
    <p class="card-text">{{ post.post_description }}</p>
  </div>
</div>
{% endfor %}
</div>
<!-- <div class="container">
<ul class="row">
  {% for post in site.posts %}
    <li class="m-1 col-md-3 bg-light" style="list-style: none;">
      <div><a href="{{ post.url | relative_url }}">{{ post.title }}</a> <small>({{ post.date | date: "%B %d, %Y" }})</small></div>
      <div>{{ post.post_description }}</div>
    </li>
  {% endfor %}
</ul>
</div> -->
<div class="mt-3 mb-3">See <a href="/categories">Post Categories</a></div>
