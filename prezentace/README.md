# Hackni chatbota: editable source

```
index.html     ← the deck: edit this
lib/           ← Reveal.js, QR library, Computer Modern fonts (don't touch)
build.py       ← packs everything into one file, hackni-chatbota.html
```

## Edit loop

1. Open the folder in VS Code (or any text editor).
2. Open `index.html` in Chrome by double-clicking it.
3. Edit, save, and press **Cmd/Ctrl + R** in the browser. The URL remembers the slide (`#/7`), so you stay where you were.
   For auto-reload, install the VS Code extension **Live Server** and choose "Open with Live Server".

## Where things are in index.html

| What | Where |
|---|---|
| Colors, fonts, all styles | the `<style>` block at the top, `:root { --blue … }` |
| Game settings (server, admin key, Wi-Fi fallback) | `window.GAME = { … }` just before the slides |
| Slides | each slide is one `<section>`, marked with a comment like `<!-- 6 ───────── PROMPT INJECTION ───────── -->` |
| Speaker notes | `<aside class="notes">…</aside>` inside a slide (press **S** to see them) |

## Slide recipes

**New content slide.** Copy an existing `<section>` and change the texts:

```html
<section data-section="1">            <!-- 0 intro/outro, 1 Útoky (blue), 2 Obrana (coral), 3 Omnibus (teal) -->
  <div class="frame">
    <div class="kicker">01 · Útoky</div>
    <h2>Title of the slide</h2>
    <div class="body">
      <p class="lead">One big sentence with a <span class="hl-c">highlight</span>.</p>
      <ul>
        <li class="fragment">appears on click</li>
        <li class="fragment">then this</li>
      </ul>
    </div>
  </div>
  <aside class="notes">What I want to say here.</aside>
</section>
```

`data-section` controls everything automatically: the color, the dot in the top navigation and the logo triangle in the corner.

**Building blocks** you can paste into `<div class="body">`:

```html
<div class="block blue"><div class="bt">Title</div><div class="bb">Text</div></div>   <!-- also: coral, teal -->
<div class="cols two"> … two columns … </div>                                           <!-- or: cols three -->
<p class="thm"><span class="lab">Definice 2</span> (name). <span class="tx">Italic statement.</span></p>
<pre class="code">code here</pre>
<div class="chat"><div class="msg user"><span class="who">Útočník</span>…</div><div class="msg bot"><span class="who">Chatbot</span>…</div></div>
<table class="bk"> … LaTeX booktabs-style table … </table>
```

Text colors: `hl-b` (blue), `hl-c` (coral), `hl-t` (teal), `muted`.

**Images.** Put the file next to `index.html` (e.g. `img/screenshot.png`) and use `<img src="img/screenshot.png" style="width:100%">`.

## Make the single file again

```bash
python3 build.py
```

This creates `hackni-chatbota.html` with everything inside it, which is handy for sending or for a presentation computer without the `lib` folder. You can also simply present from `index.html` as long as `lib/` sits next to it.

PDF: open the deck in Chrome with `?print-pdf` at the end of the URL (e.g. `index.html?print-pdf`), then Print → Save as PDF, layout Landscape, margins None, with background graphics on.
