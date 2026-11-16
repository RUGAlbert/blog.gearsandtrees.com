# Blog

The blog at <https://blog.gearsandtrees.com>. Posts are Markdown files; Hugo
turns them into a static site, and GitHub Pages serves it. A post is online
about a minute after it is pushed to `main`.

It is a separate repository from the server's because nothing about it runs on
the server: there is no container, no Caddy block and no image to build. The
landing page at gearsandtrees.com only links here and reads the list of posts.

## Writing a post

```sh
hugo new content posts/my-post.md
```

This starts a post from `archetypes/posts.md`. The file name is the address, so
`posts/my-post.md` is `blog.gearsandtrees.com/my-post/`. Once a post is out,
leave its file name alone, or every link to it breaks.

The front matter at the top:

| Field     | What it does                                                                  |
| --------- | ----------------------------------------------------------------------------- |
| `title`   | The heading, the tab title and the title in link previews.                    |
| `date`    | When it was published, as `YYYY-MM-DD`. The lists are newest first by this.   |
| `summary` | A sentence or two under the title in the lists, the feed and link previews.   |
| `draft`   | `true` keeps the post off the site. Delete the line to publish.               |

The title is already the page's `<h1>`, so headings in the post start at `##`.

A post with images goes in a folder of its own, with the text in `index.md` and
the images beside it:

```
content/posts/my-post/
├── index.md        ![A diagram of the proxy](diagram.png)
└── diagram.png
```

The address is the folder's name, the same as it would be for `my-post.md`.

## Previewing

```sh
hugo server -D
```

Serves the site at <http://localhost:1313> and reloads the page on every save.
`-D` includes drafts; leave it off to see exactly what will be published.

## Publishing

Push to `main`. `.github/workflows/deploy.yml` builds the site and publishes it;
its progress is in the Actions tab.

Two things to know:

- **A post dated in the future stays hidden** until the first build after that
  date. Pushing anything triggers one, and so does Actions → Deploy → Run
  workflow.
- **The repository is public**, because GitHub Pages is free only for public
  repositories. Drafts are published to GitHub even though they are not on the
  site, so a post that should stay private until it is ready belongs on a
  branch.

## Setting it up

Once, when the repository is first created. The GitHub steps are in the
repository's or account's settings; `<user>` is the GitHub user or organisation
that owns the repository.

1. **Create the repository** on GitHub, public, and push this one to it.
2. **Let Pages take the site from the workflow:** Settings → Pages → Build and
   deployment → Source: *GitHub Actions*. If the first deploy ran before this
   and failed, run it again from the Actions tab. The site is then at
   `https://<user>.github.io/<repository>/`.
3. **Verify the domain**, before pointing it at GitHub: account (or
   organisation) Settings → Pages → Add a domain → `gearsandtrees.com`, and
   publish the `TXT` record it asks for. This stops any other GitHub account
   from serving its own site on `blog.gearsandtrees.com` if this repository is
   ever deleted or renamed.
4. **Point the subdomain at GitHub:** a `CNAME` record for `blog` with the value
   `<user>.github.io`, without the repository name.
5. **Set the custom domain:** Settings → Pages → Custom domain →
   `blog.gearsandtrees.com`. Once the DNS check passes, tick *Enforce HTTPS*;
   the certificate can take a few minutes to appear.
6. **Redeploy** from the Actions tab. The links in the site are built for the
   address Pages reports at build time, so the build from before step 5 still
   points at `<user>.github.io/<repository>/`.

No `CNAME` file is needed in the repository: with a workflow deploy, the custom
domain lives in the Pages settings.

## The landing page's list of posts

The site also writes `/index.json`, every post newest first:

```json
{
  "posts": [
    {
      "title": "Welcome to the blog",
      "date": "2026-11-16",
      "summary": "What this blog is for, and what to expect from it.",
      "url": "https://blog.gearsandtrees.com/welcome/"
    }
  ]
}
```

The landing page fetches it to show the latest few. GitHub Pages allows that
from any site, so neither side needs any setup for it. The template is
`layouts/home.json`; a renamed field there has to be renamed on the landing page
too.

The feed for readers is `/index.xml` (RSS), and every page links to it.

## What is where

| Path                           | What it holds                                                         |
| ------------------------------ | --------------------------------------------------------------------- |
| `hugo.toml`                    | The site's settings: address, title, post addresses, outputs.         |
| `content/_index.md`            | The front page's title and the line under it.                        |
| `content/posts/`               | The posts.                                                            |
| `archetypes/posts.md`          | What `hugo new content posts/...` starts a post from.                 |
| `layouts/baseof.html`          | The frame around every page: `<head>`, the column, the footer.        |
| `layouts/home.html`            | The front page: the list of posts.                                    |
| `layouts/page.html`            | One post.                                                             |
| `layouts/404.html`             | What Pages serves for an address with no page.                        |
| `layouts/home.json`            | `/index.json`, for the landing page.                                  |
| `layouts/_partials/`           | Pieces used by more than one page: the post list and the date.        |
| `assets/css/main.css`          | All the styles.                                                       |
| `static/`                      | Copied into the site as it is: the icons.                             |
| `.github/workflows/deploy.yml` | The build and deploy.                                                 |

The palette and type in `main.css` are copied from the landing page
(`server/landing/src/styles.css`), so the blog looks like the rest of the site.
A change to one has to be made in the other too.

## Updating Hugo

The workflow pins Hugo's version (`HUGO_VERSION` in `deploy.yml`), because a
new release can change how templates behave. Keep it at the version installed
locally, which `hugo version` prints, so the site that is published is the one
that was previewed. When upgrading, upgrade locally first, check the site with
`hugo server`, then change the pin.
