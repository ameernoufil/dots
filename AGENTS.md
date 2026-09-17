# AGENTS.md

Personal macOS dotfiles in a public GitHub repo. README.md maps every file to its live path.

- Commit nothing tied to an employer: company or product names, internal hosts, gateway URLs, service accounts, MDM app IDs, work emails. Keep those in gitignored `.zshenv` (env vars, secrets) or `.zshrc.local` (shell functions).
- Commit with the repo-local git identity. The global identity is a work email.
- Never bypass the pre-push hook.
- Files are symlinked into `$HOME` by hand. A new config gets a row in the README Layout table.
- `CLAUDE.md` is a symlink to this file. Edit `AGENTS.md`.
