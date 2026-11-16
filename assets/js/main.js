// The blog's one script. Every page works without it; it adds two things:
//
// - a copy button on each code block, where the browser allows copying;
// - in a post's table of contents, a mark on the section being read.

(function () {
  'use strict';

  // The buttons are in the HTML, hidden, and only shown here, so a browser
  // without the clipboard (or without this script) has no dead button.
  if (navigator.clipboard) {
    document.querySelectorAll('.code-copy').forEach(function (button) {
      button.hidden = false;
      button.addEventListener('click', function () {
        // The code is the last <pre> in the block: with `linenos=table` the
        // line numbers are in a <pre> of their own before it. Line numbers
        // written inline are taken out of a copy before reading its text.
        var blocks = button.closest('.code').querySelectorAll('pre');
        var pre = blocks[blocks.length - 1].cloneNode(true);
        pre.querySelectorAll('.ln, .lnt').forEach(function (number) {
          number.remove();
        });
        navigator.clipboard.writeText(pre.textContent).then(
          function () {
            show(button, 'Copied');
          },
          function () {
            show(button, 'Copy failed');
          },
        );
      });
    });
  }

  function show(button, text) {
    button.textContent = text;
    clearTimeout(button.resetTimer);
    button.resetTimer = setTimeout(function () {
      button.textContent = 'Copy';
    }, 1600);
  }

  // The current section is the last heading that has scrolled past a line
  // near the top of the window, below where a link to a heading leaves it
  // (scroll-padding-top in main.css). Before the first heading, the first one
  // counts.
  var toc = document.querySelector('[data-toc]');
  if (toc) {
    var links = Array.prototype.slice.call(toc.querySelectorAll('a[href^="#"]'));
    var headings = links.map(function (link) {
      return document.getElementById(decodeURIComponent(link.hash.slice(1)));
    });
    var line = 80;
    var queued = false;

    var update = function () {
      queued = false;
      var current = 0;
      headings.forEach(function (heading, i) {
        if (heading && heading.getBoundingClientRect().top < line) {
          current = i;
        }
      });
      links.forEach(function (link, i) {
        if (i === current) {
          link.setAttribute('aria-current', 'true');
        } else {
          link.removeAttribute('aria-current');
        }
      });
    };

    window.addEventListener(
      'scroll',
      function () {
        if (!queued) {
          queued = true;
          requestAnimationFrame(update);
        }
      },
      { passive: true },
    );
    update();
  }
})();
