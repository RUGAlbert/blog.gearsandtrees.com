# Writing and previewing the blog. Publishing is a push to main; see README.md.

# List the available recipes.
default:
    @just --list

# The file name is the post's address, so `just new my-post` is
# blog.gearsandtrees.com/my-post/. It starts as a draft, from
# archetypes/posts.md.

# Start a post, e.g. `just new my-post`.
new slug:
    hugo new content 'posts/{{slug}}.md'

# A post with images needs a folder of its own, the images beside index.md. The
# address is still the folder's name, the same as for `just new`.

# Start a post that has images, e.g. `just new-bundle my-post`.
new-bundle slug:
    hugo new content 'posts/{{slug}}/index.md'

# Serve the site with drafts, reloading the page on every save.
dev port="1313":
    hugo server --buildDrafts --port {{port}}

# Without drafts, this is exactly what a push would publish.

# Serve the site as it would be published.
preview port="1313":
    hugo server --port {{port}}

# The same build the deploy workflow runs, apart from the address, which comes
# from hugo.toml here instead of from Pages. Useful for checking that the site
# builds before pushing. The output is in public/, which git ignores.

# Build the site into public/, as the deploy does.
build:
    hugo build --gc --minify --cleanDestinationDir

# Remove the build output and Hugo's cache of processed assets.
clean:
    rm -rf public resources/_gen .hugo_build.lock

# The workflow pins Hugo's version, and the site that is published should be
# the one that was previewed. Run this after upgrading Hugo locally; see
# "Updating Hugo" in README.md.

# Check that the local Hugo is the version deploy.yml pins.
check-hugo:
    #!/usr/bin/env bash
    set -euo pipefail
    installed=$(hugo version | sed -E 's/^hugo v([0-9.]+).*/\1/')
    pinned=$(sed -nE 's/^ *HUGO_VERSION: *([0-9.]+).*/\1/p' .github/workflows/deploy.yml)
    if [ "$installed" = "$pinned" ]; then
        echo "Hugo $installed, the version deploy.yml pins."
    else
        echo "Hugo $installed is installed, but deploy.yml pins $pinned." >&2
        exit 1
    fi

# Regenerates assets/css/syntax.css and keeps the comment at its top, which the
# plain `hugo gen chromastyles` would overwrite. Styles are previewed at
# https://xyproto.github.io/splash/docs/; it has to be a dark one, because code
# blocks have a dark background in light mode too.

# Change the colours of highlighted code, e.g. `just syntax github-dark`.
syntax style:
    #!/usr/bin/env bash
    set -euo pipefail
    file=assets/css/syntax.css
    # Generated first, so an unknown style fails before the file is touched.
    css=$(hugo gen chromastyles --style='{{style}}')
    header=$(sed '/^ \*\//q' "$file")
    printf '%s\n\n%s\n' "$header" "$css" > "$file"
    echo "Wrote $file with the {{style}} style."
