```json
{
  "summary": "The only durable knowledge not already in the claim index is the prompt-side half of the F9b contract: agent/SOUL.md rule 10 and agent/review-prompt.md now require the model to emit `path:LINE` citations for new lines, which is what makes precise inline anchoring possible, plus the explicit no-invented-line-numbers rule.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": "agent",
      "action": "merge",
      "section": "Design decisions",
      "content": "- F9b splits the precise-anchor feature across prompt and script: the model side is `agent/SOUL.md` rule 10 (\"when a defect is on a specific **new** line you saw in the diff, cite `path:LINE`\") plus the `agent/review-prompt.md` Key findings **File** column preferring `path:LINE` when the line is visible in the diff. Without those two, `scripts/post-inline-comments.py` has no `line_hint` to consume and always degrades to the F9 nearest/first anchor.\n- The citation rule is deliberately scoped to **new** (`+`) lines only, matching the reviewer's added-lines scope — a `path:LINE` pointing at unchanged context is not a usable anchor for a GitHub review comment.",
      "evidence": [
        "agent/SOUL.md rule 10: cite path:LINE for new lines only; never invent",
        "agent/review-prompt.md Key findings File column prefers path:LINE when seen in diff"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": "agent",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- \"Never invent LINE\" in SOUL rule 10 is a hard API constraint, not style: a hallucinated line number that is not a changed `+` line makes GitHub reject the inline review comment (HTTP 422), so a confidently wrong citation is worse than no citation at all.\n- Reformatting or dropping the `path:LINE` convention from the Key findings **File** column silently downgrades anchors to nearest/first instead of erroring — the same class of invisible prompt/parser drift as the `**Verdict:**` textual contract.",
      "evidence": [
        "Do not invent line numbers (422 risk on GitHub)",
        "Only pins to changed + lines so GitHub accepts the review comment"
      ],
      "confidence": "high"
    }
  ]
}
```
