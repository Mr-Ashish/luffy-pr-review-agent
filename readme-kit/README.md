# readme-kit

Compile **intent** (theme + pack + config) into GitHub-safe README Markdown and light branding assets.

**Spine:** Recipe δ (Luffy-native) on β (theme + brand pack). See [docs/README-KIT-MVP.md](../docs/README-KIT-MVP.md).

## Commands

```bash
# from monorepo root
node readme-kit/bin/readme-kit.mjs themes
node readme-kit/bin/readme-kit.mjs packs
node readme-kit/bin/readme-kit.mjs build readme-kit/examples/luffy/readme.config.json -o README.generated.md
node readme-kit/bin/readme-kit.mjs init --theme flame --pack ai-agent
node readme-kit/bin/readme-kit.mjs brand ai-agent --theme flame --dir ./branding
```

## Layout

```text
themes/     flame, terminal (tokens / badge colors)
packs/      ai-agent (section order)
src/        build + render + asset generators
examples/   luffy config + mermaid diagrams
```

Zero npm dependencies (Node ≥ 18).
