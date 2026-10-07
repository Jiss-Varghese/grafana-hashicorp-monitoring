# Prometheus Metrics Research

## Nomad

### Metrics endpoint

`/v1/metrics?format=prometheus`

### Areas investigated

- Server status
- Client status
- Allocations
- Allocation failures
- Jobs
- Deployments
- CPU
- Memory
- Raft
- RPC

### Important metrics

Metrics were collected from the actual Nomad instance rather than relying only on example queries.

---

## Consul

### Metrics endpoint

`/v1/agent/metrics?format=prometheus`

### Areas investigated

- Service health
- Agent health
- Raft
- Leadership
- Network
- API
- Runtime
- Autopilot

### Important metrics

Metrics were collected from the actual Consul instance.

---

## Vault

### Metrics endpoint

`/v1/sys/metrics?format=prometheus`

### Areas investigated

- Token activity
- Authentication
- Secret engines
- Requests
- Latency
- Errors
- Audit-related activity

### Important metrics

Metrics were collected from the actual Vault instance.