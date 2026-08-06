# F67 Modal e2e — complex milvus#6

| Check | Result |
|-------|--------|
| Version | `0.8.0-f67` |
| Target | Mr-Ashish/milvus#6 (upstream #51886 schema gate, 27 files) |
| `log_streaming` | true |
| Live `[orch:err]` stages | yes (preload → assemble → hermes → post) |
| `F67 stream logs ON` | yes |
| `lens_pack` | **go** (auto from F63) |
| F49 recovery | tool_turns **0→21** |
| agent-loop | 48 messages, 21 tool turns |
| hermes stderr | ~55KB captured |
| Review | APPROVE 95 |
| orch_rc / post_rc | 0 / 0 |
| Modal run | https://modal.com/apps/mr-ashish/main/ap-JAoX2PGY5ZrIIvyfZpjN2o |
| Comment | posted on PR #6 |
| Elapsed | ~131s |

