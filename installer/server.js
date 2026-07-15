import { createServer } from "node:http";

const port = process.env.PORT ?? 3000;
const setupScriptUrl =
  "https://raw.githubusercontent.com/frixaco/dotfiles/main/setup.sh";

const server = createServer((request, response) => {
  if (request.method !== "GET" && request.method !== "HEAD") {
    response.writeHead(405, {
      Allow: "GET, HEAD",
      "Content-Type": "text/plain; charset=utf-8",
    });
    response.end("Method not allowed\n");
    return;
  }

  const pathname = new URL(request.url ?? "/", "http://localhost").pathname;

  if (pathname === "/healthz") {
    response.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
    response.end("OK\n");
    return;
  }

  if (pathname !== "/") {
    response.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    response.end("Not found\n");
    return;
  }

  response.writeHead(307, {
    "Cache-Control": "no-store",
    Location: setupScriptUrl,
  });
  response.end();
});

server.listen(port, () => {
  console.log(`Dotfiles installer redirect listening on port ${port}`);
});
