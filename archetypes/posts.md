---
title: '{{ replace .File.ContentBaseName "-" " " | strings.FirstUpper }}'
date: {{ time.Now.Format "2006-01-02" }}
# A sentence or two, shown under the title in the lists and in link previews.
summary: ''
# Not published until this line is removed. `hugo server -D` shows it anyway.
draft: true
# The title above is already the page's heading, so the post's own headings
# start at `##`.
---

