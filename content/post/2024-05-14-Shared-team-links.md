+++
title = "Shared team links"
date = "2024-05-14"
+++

Every team I've ever worked with has a collection links to shared resources. Things like logging dashboards for each environment. This tends to quickly get messy to manage and hard to onboard new staff. While adding links to a Confluence page recently, I wondered if a better solution existed.

Let me introduce you to [static-marks](https://darekkay.com/static-marks/) written by Darek Kay. This application will take a yaml file with links in and create a static HTML site with integrated search.

I created a small demo repository to test this application out. On push to `master`, it runs a GitHub Action to render out the HTML file and upload it to GitHub Pages. Now, we have a central location for these shared links, but managed in code via Git. It also has a deterministic output, so no need to worry about bad edits or messing around with Confluence formatting!

https://github.com/francis-io/demo-bookmarks
