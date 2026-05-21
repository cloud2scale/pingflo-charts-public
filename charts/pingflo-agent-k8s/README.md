# pingflo-agent-k8s

Helm chart for the [pingflo](https://pingflo.ai) Kubernetes discovery
agent. Read-only watch on namespaces, nodes, deployments,
statefulsets, daemonsets, services, pods, events, ingresses,
endpoints. Outbound HTTPS only; no inbound ports.

```bash
helm repo add pingflo https://charts.pingflo.ai
helm repo update
```

> The pingflo project UI renders an install snippet tailored to each
> minted agent. You usually don't compose the command below by hand
> — copy from the UI.

## Quick install

```bash
helm upgrade --install pingflo-k8s pingflo/pingflo-agent-k8s \
  --namespace pingflo --create-namespace \
  --set token=<one-shot-token-from-pingflo-ui> \
  --set clusterName=prod-us-east-1
```

`clusterName` is **required** for multi-cluster installs — pingflo
identifies each resource by `<cluster>/<namespace>/<kind>/<name>`,
so two K8s agents in the same project must use distinct cluster
labels. Pick something stable + meaningful (region, account,
environment).

## Locked-down clusters

For clusters that disallow `ClusterRole` / `ClusterRoleBinding`,
scope the agent to a namespace allow-list — the chart writes a
per-namespace `Role` + `RoleBinding` for each entry:

```bash
helm upgrade --install pingflo-k8s pingflo/pingflo-agent-k8s \
  --namespace pingflo --create-namespace \
  --set token=<one-shot-token-from-pingflo-ui> \
  --set clusterName=prod-us-east-1 \
  --set rbac.clusterScope=false \
  --set 'rbac.namespaces={default,production,billing}'
```

The agent only watches the listed namespaces; cluster-scoped
resources (namespaces, nodes) are skipped automatically.

## Values reference

| Key | Default | Description |
|---|---|---|
| `image.repository` | `public.ecr.aws/p9w7u7k0/agent/k8s` | K8s agent image. |
| `image.tag` | `""` | Falls back to `.Chart.AppVersion`. |
| `image.pullPolicy` | `IfNotPresent` | |
| `imagePullSecrets` | `[]` | For private mirrors. |
| `token` | `""` | **Required.** One-shot pairing token. |
| `clusterName` | `""` | **Required** for multi-cluster installs. |
| `rbac.create` | `true` | |
| `rbac.clusterScope` | `true` | `false` → per-namespace Role+RoleBinding. |
| `rbac.namespaces` | `[]` | Allow-list when `clusterScope=false`. |
| `replicaCount` | `1` | Singleton; keep at 1. |
| `serviceAccount.create` | `true` | |
| `serviceAccount.name` | `""` | Falls back to the release name. |
| `serviceAccount.annotations` | `{}` | |
| `resources.*` | small | See `values.yaml`. |
| `nodeSelector` / `tolerations` / `affinity` | `{}` / `[]` / `{}` | |
| `extraEnv` | `[]` | List of `{name, value}`. |
| `podSecurityContext` | non-root | |
| `securityContext` | read-only root fs, no caps | |

## Upgrades

```bash
helm upgrade pingflo-k8s pingflo/pingflo-agent-k8s \
  --reuse-values \
  --set token=<new-token>
```

`--reuse-values` keeps every install-time flag (cluster name, RBAC
scope, …) and rotates only the one you pass.

## Sister charts

- [`pingflo-agent-aws`](../pingflo-agent-aws/README.md) — AWS
  discovery agent.
