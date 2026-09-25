---
name: sx-cloudflare
description: Rules for working with Cloudflare and Wrangler. Use whenever the task involves Cloudflare (Workers, Pages, D1, KV, R2, wrangler.toml / wrangler.jsonc) or the wrangler CLI.
---

# Cloudflare

- **Never run `wrangler` yourself.** When a step needs a wrangler command, give the user
  the exact command, ask them to run it, and wait for them to report the result.
