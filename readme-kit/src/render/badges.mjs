function enc(s) {
  // shields.io expects fully percent-encoded label/message (keep %2F for slashes)
  return encodeURIComponent(String(s));
}

/** Build shields.io image markdown for a badge descriptor */
export function renderBadge(badge, theme, repo) {
  const style = theme.badgeStyle || "for-the-badge";
  const owner = repo?.owner || "owner";
  const name = repo?.name || "repo";
  const branch = repo?.default_branch || "main";
  const ink = theme.colors.ink;
  const flame = theme.colors.flame;

  if (badge.type === "workflow") {
    const wf = badge.workflow;
    const label = badge.label || "CI";
    const url = `https://img.shields.io/github/actions/workflow/status/${owner}/${name}/${wf}?branch=${branch}&style=${style}&label=${enc(label)}&logo=githubactions&logoColor=white`;
    const href = `https://github.com/${owner}/${name}/actions/workflows/${wf}`;
    return `[![${label}](${url})](${href})`;
  }

  if (badge.type === "last-commit") {
    const url = `https://img.shields.io/github/last-commit/${owner}/${name}/${branch}?style=${style}&logo=git&logoColor=white&color=${ink}`;
    return `[![Last commit](${url})](https://github.com/${owner}/${name}/commits/${branch})`;
  }

  if (badge.type === "license") {
    const lic = badge.message || "MIT";
    const color = badge.color || theme.colors.gold;
    const url = `https://img.shields.io/badge/license-${enc(lic)}-${color}?style=${style}&labelColor=${ink}&logo=open-source-initiative&logoColor=${color}`;
    return `![License](${url})`;
  }

  // static
  const label = badge.label || "info";
  const message = badge.message || "";
  const color = badge.color || flame;
  const logo = badge.logo ? `&logo=${enc(badge.logo)}&logoColor=white` : "";
  const url = `https://img.shields.io/badge/${enc(label)}-${enc(message)}-${color}?style=${style}${logo}`;
  if (badge.href) {
    return `[![${label}](${url})](${badge.href})`;
  }
  return `![${label}](${url})`;
}

export function renderBadgeRow(badges, theme, repo) {
  if (!badges?.length) return "";
  return badges.map((b) => renderBadge(b, theme, repo)).join("\n");
}
