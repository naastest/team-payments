# team-payments

Payments team repository for namespace definitions and application manifests.

## Repository layout

```
namespaces/{env}/     — Namespace declarations (labels, cost-center, compliance)
apps/helm/{env}/      — Helm service workloads (Deployment + Service + HPA + Ingress)
apps/raw/{env}/       — Raw manifests per namespace (CronJobs, ConfigMaps, Jobs, RBAC…)
docs/                 — How-to guides
```

## Namespace Ownership

| Directory | Who can merge | Approval needed |
|-----------|--------------|-----------------|
| `namespaces/dev/` | Team leads | Team self-approve |
| `namespaces/test/` | Team leads | Team self-approve |
| `namespaces/acceptance/` | Team leads | + Platform team |
| `namespaces/production/` | Team leads | + Platform team |

## Deploying Applications

### Helm services (recommended for long-running workloads)

Add a values file under `apps/helm/{env}/`. ArgoCD creates one Application per
file using the shared `service` Helm chart (Deployment + Service + HPA + Ingress).

See [docs/deploying-helm-apps.md](docs/deploying-helm-apps.md).

### Raw Kubernetes manifests (CronJobs, ConfigMaps, Jobs, RBAC, …)

Add a folder under `apps/raw/{env}/<namespace>/`. The folder name is the target
namespace. ArgoCD deploys all `.yaml` files in the folder into that namespace.

See [docs/deploying-raw-resources.md](docs/deploying-raw-resources.md).

### PR Preview environments

Open a PR. ArgoCD automatically creates one preview Application per `apps/helm/dev/`
values file on the PR branch, deploys it into `payments-preview-pr-{n}`, and posts
a GitHub comment with the preview URLs once healthy.

## Requesting a New Namespace

1. Add a `namespace.yaml` under `namespaces/{env}/` with all required `naas.io/*` labels
2. Open a PR — Kyverno dry-run validates the label schema
3. Merge after required approvals
4. ArgoCD provisions the namespace within ~2 minutes

See [NaaS onboarding docs](https://github.com/naastest/naas-platform/blob/main/docs/onboarding.md) for the full label schema.
