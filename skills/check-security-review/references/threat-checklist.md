# Threat Checklist

For each trust boundary the change touches, confirm or record a finding.

## Authentication / Authorization
- [ ] Every protected route checks identity AND permission; deny by default.
- [ ] No horizontal escalation: resources scoped to the authenticated principal (not a client-supplied id).
- [ ] No vertical escalation: role/permission checked server-side, not from a client claim.
- [ ] Session/token: expiry, rotation, revocation; no auth state trusted from the client.

## Injection
- [ ] SQL: parameterized queries only; never string-built.
- [ ] Command/shell: no shell interpolation of input; use arg arrays.
- [ ] Template/HTML: output-encoded; no raw user HTML (XSS).
- [ ] Path: no user-controlled path traversal (`../`); canonicalize + allowlist.

## Secrets & data
- [ ] No secrets in code, logs, error messages, or responses.
- [ ] Secrets from env/secret-store with least privilege.
- [ ] Sensitive/PII fields not over-returned; encrypted at rest/in transit per policy.

## Other surfaces
- [ ] Deserialization: no untrusted object/pickle/yaml-unsafe load.
- [ ] SSRF: outbound URLs from input validated/allowlisted.
- [ ] File upload: type/size validated; stored outside web root; no executable bit.
- [ ] Dependencies: no known-vulnerable versions (scan); pin/patch.
- [ ] Rate limiting / abuse on auth + expensive endpoints.
