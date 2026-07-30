import { renderBadgeRow } from "./badges.mjs";

function fence(lang, body) {
  return "```" + lang + "\n" + body.trimEnd() + "\n```";
}

function h2(title) {
  return `## ${title}\n`;
}

export function renderDocument(config, theme, pack) {
  const sections = config.sections || pack.defaultSections || [];
  const product = config.product || {};
  const content = config.content || {};
  const repo = config.repo || {};
  const parts = [];

  for (const id of sections) {
    switch (id) {
      case "hero": {
        const mark = config.hero?.mark;
        if (config.hero?.show_mark !== false && mark) {
          parts.push(`<p align="center">\n  <img src="${mark}" alt="${product.name || "logo"}" width="128" />\n</p>\n`);
        }
        parts.push(`# ${product.name || "Project"}\n`);
        if (product.tagline) {
          parts.push(`**${product.tagline}**\n`);
        }
        if (product.one_liner) {
          parts.push(`${product.one_liner}\n`);
        }
        break;
      }
      case "badges": {
        const row = renderBadgeRow(config.badges || [], theme, repo);
        if (row) parts.push(row + "\n");
        break;
      }
      case "why": {
        parts.push(h2("Why it exists"));
        parts.push((content.why || "_TODO: why_").trim() + "\n");
        break;
      }
      case "trigger": {
        parts.push(h2("Trigger"));
        const lines = content.trigger || ["@luffy review this pr"];
        parts.push(fence("text", lines.join("\n")) + "\n");
        if (content.trigger_note) {
          parts.push(content.trigger_note.trim() + "\n");
        }
        break;
      }
      case "architecture": {
        parts.push(h2("High-level architecture"));
        const m = content.architecture_mermaid;
        if (m) parts.push(fence("mermaid", m) + "\n");
        if (content.architecture_note) {
          parts.push(content.architecture_note.trim() + "\n");
        }
        break;
      }
      case "e2e": {
        parts.push(h2("E2E flow"));
        const m = content.e2e_mermaid;
        if (m) parts.push(fence("mermaid", m) + "\n");
        if (content.pipeline_mermaid) {
          parts.push("**Pipeline stages**\n");
          parts.push(fence("mermaid", content.pipeline_mermaid) + "\n");
        }
        break;
      }
      case "setup": {
        parts.push(h2("Setup (target repo)"));
        const steps = content.setup_steps || [];
        steps.forEach((s, i) => parts.push(`${i + 1}. ${s}`));
        parts.push("");
        break;
      }
      case "local": {
        parts.push(h2("Local dry-run"));
        parts.push(fence("bash", content.local_commands || "./scripts/review-local.sh owner/repo 123") + "\n");
        break;
      }
      case "traces": {
        parts.push(h2("Traces"));
        parts.push((content.traces || "Per-run redacted traces upload as Actions artifacts.").trim() + "\n");
        if (content.traces_layout) {
          parts.push(fence("text", content.traces_layout) + "\n");
        }
        if (content.traces_download) {
          parts.push(fence("bash", content.traces_download) + "\n");
        }
        break;
      }
      case "memory": {
        parts.push(h2("Central hub memory"));
        parts.push((content.memory || "Published under memory/repos/{owner}--{repo}/.").trim() + "\n");
        if (content.memory_layout) {
          parts.push(fence("text", content.memory_layout) + "\n");
        }
        break;
      }
      case "layout": {
        parts.push(h2("Layout"));
        parts.push(fence("text", content.layout || "agent/\nscripts/\nmemory/") + "\n");
        break;
      }
      case "docs": {
        parts.push(h2("Docs"));
        const links = content.docs_links || [];
        for (const d of links) {
          parts.push(`- [${d.title}](${d.path})`);
        }
        parts.push("");
        break;
      }
      case "limits": {
        parts.push(h2("Limits (v1)"));
        const limits = content.limits || [];
        for (const L of limits) parts.push(`- ${L}`);
        parts.push("");
        break;
      }
      case "footer": {
        const f = content.footer || `${product.name || "Project"} · built with readme-kit`;
        parts.push("---\n");
        parts.push(`*${f}*\n`);
        break;
      }
      default:
        parts.push(`<!-- unknown section: ${id} -->\n`);
    }
  }

  return parts.join("\n").replace(/\n{3,}/g, "\n\n") + "\n";
}
