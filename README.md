# pingflo-charts

Public Helm charts for [pingflo](https://pingflo.ai) agents.

```bash
helm repo add pingflo https://charts.pingflo.ai
helm repo update
```

## Charts

| Chart | Description |
|---|---|
| [`pingflo-agent-aws`](charts/pingflo-agent-aws/README.md) | AWS discovery agent. |
| [`pingflo-agent-k8s`](charts/pingflo-agent-k8s/README.md) | Kubernetes discovery agent. |

The pingflo project UI renders an install snippet for you whenever
you add an agent — copy that command. The per-chart READMEs above
cover the values reference and authentication options if you need to
script the install yourself.
