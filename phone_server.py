from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parent


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        return


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    handler = partial(QuietHandler, directory=str(ROOT))
    server = ThreadingHTTPServer(("0.0.0.0", port), handler)
    server.serve_forever()


if __name__ == "__main__":
    main()
