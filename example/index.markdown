---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---

# Events

{% include post_list.html data=site.events date='start_date' %}

# Petitions

{% include post_list.html data=site.petitions date='start_date' %}

# Event Campaigns

{% include post_list.html data=site.event_campaigns date='start_date' %}

# Campaigns

{% include post_list.html data=site.campaigns date='start_date' %}

# Forms

{% include post_list.html data=site.forms %}

# Email campaigns

{% assign posts = site.advocacy_campaigns | where: "categories", "email" %}
{% include post_list.html data=posts %}

# Call campaigns

{% assign posts = site.advocacy_campaigns | where: "categories", "call" %}
{% include post_list.html data=posts %}