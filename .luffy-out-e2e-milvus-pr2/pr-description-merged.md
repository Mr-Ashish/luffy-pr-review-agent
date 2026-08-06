## Luffy eval corpus

Exact port of [milvus-io/milvus#51962](https://github.com/milvus-io/milvus/pull/51962) for **Luffy** PR-review e2e (not for milvus-io merge).

| Field | Value |
|-------|-------|
| Upstream | milvus-io#51962 |
| Title | enhance: raise the bloom_match filter ceiling to 50M members |
| Files | 8 (Go + C++ + yaml + design doc) |
| +/− | +259/−37 |
| Base/Head | exact upstream parent/head SHAs |

### Files
- `client/milvusclient/bloom_filter.go`, `client/sbbf/sbbf.go`
- `configs/milvus.yaml`, `pkg/util/paramtable/component_param.go`
- `internal/core/src/exec/expression/BloomFilterExpr.cpp`
- `internal/parser/planparserv2/bloom_match.go` + test
- design doc

Multi-language config+exec path — good for multi-lens / tools depth eval.

Keep open for repeated Luffy runs.