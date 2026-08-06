## Luffy eval corpus

Exact port of [milvus-io/milvus#51991](https://github.com/milvus-io/milvus/pull/51991) for **Luffy** PR-review e2e (not for milvus-io merge).

| Field | Value |
|-------|-------|
| Upstream | milvus-io#51991 |
| Title | enhance: skip insert body parsing without functions |
| Files | 6 (Go) |
| +/− | +104/−37 |
| Base/Head | exact upstream parent/head SHAs |

### Files
- `internal/util/function/manager.go` + `manager_test.go`
- `internal/streamingnode/.../function_materializer.go` + `shard_interceptor_test.go`
- `internal/flushcommon/writebuffer/write_buffer_test.go`
- `internal/querynodev2/delegator/delegator_test.go`

Keep open for repeated Luffy runs. Do not merge to milvus-io.