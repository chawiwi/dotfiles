from pathlib import Path
import sys

import vim


DEFAULT_HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>Quench - Neovim IPython Integration</title>
</head>
<body>
    <h1>Quench</h1>
    <p>Neovim IPython Integration Server</p>
    <p>WebSocket endpoint: <code>/ws/{kernel_id}</code></p>
</body>
</html>
"""


def _plugin_python_root():
    plugin_root = vim.vars.get("quench_nvim_plugin_root", "")
    if not plugin_root:
        return None
    return Path(plugin_root) / "rplugin" / "python3"


plugin_python_root = _plugin_python_root()
if plugin_python_root and str(plugin_python_root) not in sys.path:
    sys.path.insert(0, str(plugin_python_root))

try:
    from quench.web_server import WebServer, web
except Exception:
    WebServer = None
    web = None


def _inject_css(html, css):
    if not css or "quench-user-style" in html:
        return html

    style_tag = '\n<style id="quench-user-style">\n' + css + "\n</style>\n"
    if "</head>" in html:
        return html.replace("</head>", style_tag + "</head>", 1)
    if "</style>" in html:
        return html.replace("</style>", "</style>" + style_tag, 1)
    return style_tag + html


if WebServer is not None and web is not None and not getattr(WebServer, "_quench_user_style_patch", False):
    async def _handle_index_with_user_style(self, request):
        try:
            frontend_path = Path(self._get_frontend_path())
            index_path = frontend_path / "index.html"
            if index_path.exists():
                content = index_path.read_text(encoding="utf-8")
            else:
                content = DEFAULT_HTML

            css = ""
            if getattr(self, "nvim", None) is not None:
                try:
                    css = self.nvim.vars.get("quench_nvim_custom_css", "")
                except Exception:
                    css = ""

            content = _inject_css(content, css)
            return web.Response(text=content, content_type="text/html")
        except Exception as exc:
            if getattr(self, "_logger", None) is not None:
                self._logger.error(f"Error serving index page: {exc}")
            return web.Response(text="Internal Server Error", status=500)

    WebServer._handle_index = _handle_index_with_user_style
    WebServer._quench_user_style_patch = True
