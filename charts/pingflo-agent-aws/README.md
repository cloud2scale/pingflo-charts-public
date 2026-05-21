# pingflo-agent-aws

Helm chart for the [pingflo](https://pingflo.ai) AWS discovery agent.
Read-only by construction: list / describe / get on EC2, RDS, EKS,
S3, Lambda, ELB, IAM, CloudWatch + friends. Outbound HTTPS only;
no inbound ports.

```bash
helm repo add pingflo https://charts.pingflo.ai
helm repo update
```

> The pingflo project UI renders an install snippet tailored to each
> agent you mint (one-shot token + correct auth flags). You usually
> don't compose the command below by hand — copy from the UI.

## Authentication — pick one

### IRSA (recommended for EKS)

Pre-create an IAM role with read-only access (`ReadOnlyAccess` is
broad; or build a least-privilege policy from `ec2:Describe*`,
`rds:Describe*`, `eks:Describe*`, `s3:List*`, etc.), then pass the
role ARN at install time. The chart annotates the ServiceAccount
with `eks.amazonaws.com/role-arn` for the AWS SDK's OIDC pickup.

```bash
helm upgrade --install pingflo-aws pingflo/pingflo-agent-aws \
  --namespace pingflo --create-namespace \
  --set token=<one-shot-token-from-pingflo-ui> \
  --set aws.roleArn=arn:aws:iam::123456789012:role/pingflo-agent-aws
```

### EC2 / ECS instance role

If the pod inherits a host instance profile with read-only IAM, skip
all `aws.*` flags — the AWS SDK auto-discovers credentials.

```bash
helm upgrade --install pingflo-aws pingflo/pingflo-agent-aws \
  --namespace pingflo --create-namespace \
  --set token=<one-shot-token-from-pingflo-ui>
```

### Static IAM access keys

For environments without IRSA / instance roles. Stored in the
chart's Secret next to the pairing token.

```bash
helm upgrade --install pingflo-aws pingflo/pingflo-agent-aws \
  --namespace pingflo --create-namespace \
  --set token=<one-shot-token-from-pingflo-ui> \
  --set aws.accessKeyId=AKIA... \
  --set aws.secretAccessKey=...
```

## Values reference

| Key | Default | Description |
|---|---|---|
| `image.repository` | `public.ecr.aws/p9w7u7k0/agent/aws` | AWS agent image. |
| `image.tag` | `""` | Falls back to `.Chart.AppVersion`. |
| `image.pullPolicy` | `IfNotPresent` | |
| `imagePullSecrets` | `[]` | For private mirrors. |
| `token` | `""` | **Required.** One-shot pairing token. |
| `aws.roleArn` | `""` | IRSA — set to annotate the ServiceAccount. |
| `aws.accessKeyId` | `""` | Static IAM user access key. |
| `aws.secretAccessKey` | `""` | Static IAM user secret. |
| `aws.region` | `""` | Optional override. |
| `replicaCount` | `1` | Agents are singletons; keep at 1. |
| `serviceAccount.create` | `true` | |
| `serviceAccount.name` | `""` | Falls back to the release name. |
| `serviceAccount.annotations` | `{}` | Merged with the IRSA annotation. |
| `resources.*` | small | See `values.yaml`. |
| `nodeSelector` / `tolerations` / `affinity` | `{}` / `[]` / `{}` | |
| `extraEnv` | `[]` | List of `{name, value}` — proxy vars, etc. |
| `podSecurityContext` | non-root | |
| `securityContext` | read-only root fs, no caps | |

## Upgrades

```bash
helm upgrade pingflo-aws pingflo/pingflo-agent-aws \
  --reuse-values \
  --set token=<new-token>
```

`--reuse-values` keeps every install-time flag and rotates only the
one you pass. The Deployment's `checksum/secret` annotation triggers
a rolling pod restart.

## Sister charts

- [`pingflo-agent-k8s`](../pingflo-agent-k8s/README.md) — Kubernetes
  discovery agent.
