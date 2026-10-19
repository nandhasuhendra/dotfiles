#!/usr/bin/env python3
"""Serve OpenSpec change markdown to a phone browser. Read-only, no auth."""

import argparse
import html
import http.server
import secrets
import socket
from pathlib import Path
from urllib.parse import unquote, urlsplit

try:
    from markdown_it import MarkdownIt
except ImportError:
    MarkdownIt = None

CSS = """
:root { color-scheme: light dark; --line: #8a8a8a; }
* { box-sizing: border-box; }
body { max-width: 48rem; margin: 0 auto; padding: 1.25rem; line-height: 1.55;
       font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }
h1, h2, h3 { line-height: 1.25; }
a { color: inherit; text-underline-offset: .2em; }
table { border-collapse: collapse; width: 100%; display: block; overflow-x: auto; }
th, td { border: 1px solid var(--line); padding: .4rem .55rem; text-align: left;
         vertical-align: top; }
pre, code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
pre { overflow-x: auto; padding: 1rem; border: 1px solid var(--line); }
code { overflow-wrap: anywhere; }
li { margin: .3rem 0; }
.mermaid { overflow-x: auto; }
.mermaid svg { max-width: 100%; height: auto; }
.muted { opacity: .7; }
nav ul { padding-left: 1.2rem; }
"""


MERMAID_URL = "https://cdn.jsdelivr.net/npm/mermaid@12.2.0/dist/mermaid.esm.min.mjs"
MERMAID_SCRIPT = f"""
const blocks = [...document.querySelectorAll('pre > code.language-mermaid')];
if (blocks.length) {{
  try {{
    const {{ default: mermaid }} = await import('{MERMAID_URL}');
    for (const code of blocks) {{
      const chart = document.createElement('div');
      chart.className = 'mermaid';
      chart.textContent = code.textContent;
      code.parentElement.replaceWith(chart);
    }}
    mermaid.initialize({{ startOnLoad: false, theme: 'neutral' }});
    await mermaid.run({{ querySelector: '.mermaid' }});
  }} catch (error) {{
    console.error('Mermaid render failed', error);
  }}
}}
"""


def page(title, body, nonce):
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title><style>{CSS}</style></head>
<body>{body}<script type="module" nonce="{nonce}">{MERMAID_SCRIPT}</script></body></html>"""


def render_markdown(text):
    if MarkdownIt is None:
        return f"<pre>{html.escape(text)}</pre>"
    md = MarkdownIt("commonmark", {"html": False, "linkify": True})
    md.enable(["table", "strikethrough"])
    return md.render(text)


def title_of(path):
    for line in path.read_text(errors="replace").splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return path.stem.replace("-", " ")


class DocsHandler(http.server.BaseHTTPRequestHandler):
    root = Path(".")
    files = []

    def do_GET(self):
        path = unquote(urlsplit(self.path).path)
        if path in ("/", "/index.html"):
            self.send_index()
            return
        if not path.startswith("/doc/"):
            self.send_error(404)
            return
        relative = path[len("/doc/"):]
        target = (self.root / relative).resolve()
        try:
            target.relative_to(self.root)
        except ValueError:
            self.send_error(404)
            return
        if target.suffix != ".md" or not target.is_file():
            self.send_error(404)
            return
        body = render_markdown(target.read_text(errors="replace"))
        self.send_html(title_of(target), f'<p><a href="/">All changes</a></p>{body}')

    def do_HEAD(self):
        self.do_GET()

    def send_index(self):
        groups = {}
        for file in self.files:
            groups.setdefault(file.parent.relative_to(self.root).as_posix(), []).append(file)
        parts = ['<h1>OpenSpec changes</h1><p class="muted">Read-only local preview.</p>']
        for group, files in sorted(groups.items()):
            parts.append(f"<h2>{html.escape(group)}</h2><nav><ul>")
            for file in sorted(files):
                link = "/doc/" + file.relative_to(self.root).as_posix()
                parts.append(f'<li><a href="{html.escape(link)}">{html.escape(title_of(file))}</a></li>')
            parts.append("</ul></nav>")
        self.send_html("OpenSpec changes", "".join(parts))

    def send_html(self, title, body):
        nonce = secrets.token_urlsafe(16)
        data = page(title, body, nonce).encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.send_header(
            "Content-Security-Policy",
            f"default-src 'none'; style-src 'unsafe-inline'; "
            f"script-src 'nonce-{nonce}' https://cdn.jsdelivr.net; "
            "img-src data:; font-src https://cdn.jsdelivr.net",
        )
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(data)

    def log_message(self, fmt, *args):
        return


def lan_ip():
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            sock.connect(("192.0.2.1", 80))
            return sock.getsockname()[0]
    except OSError:
        return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default="openspec/changes",
                        help="directory to serve (default: openspec/changes)")
    parser.add_argument("--host", default="127.0.0.1",
                        help="bind address (use 0.0.0.0 or a Tailscale IP for phone access)")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if not root.is_dir():
        parser.error(f"not a directory: {root}")
    files = sorted(root.rglob("*.md"))
    if not files:
        parser.error(f"no markdown files under {root}")

    DocsHandler.root = root
    DocsHandler.files = files
    server = http.server.ThreadingHTTPServer((args.host, args.port), DocsHandler)
    port = server.server_address[1]

    print(f"Serving {len(files)} markdown files from {root}")
    print(f"Local: http://127.0.0.1:{port}/")
    if args.host in ("0.0.0.0", "::"):
        ip = lan_ip()
        if ip:
            print(f"Phone (same Wi-Fi): http://{ip}:{port}/")
    elif args.host not in ("127.0.0.1", "::1"):
        print(f"Phone: http://{args.host}:{port}/")
    if args.host not in ("127.0.0.1", "::1"):
        print("Read-only, no authentication. Use a trusted network or Tailscale.")
    print("Press Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
