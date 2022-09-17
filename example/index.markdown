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