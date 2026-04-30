# team-payments

Payments team repository for namespace definitions and application manifests.

## Namespace Ownership

| Directory | Who can merge | Approval needed |
|-----------|--------------|-----------------|
| `namespaces/dev/` | Team leads | Team self-approve |
| `namespaces/test/` | Team leads | Team self-approve |
| `namespaces/acceptance/` | Team leads | + Platform team |
| `namespaces/production/` | Team leads | + Platform team |

## Requesting a New Namespace

1. Add a `namespace.yaml` under the appropriate `namespaces/{env}/` directory
2. Open a PR — CI validates the label schema and runs Kyverno dry-run
3. Merge after required approvals
4. ArgoCD picks it up within ~2 minutes and provisions everything automatically

See [NaaS onboarding docs](https://github.com/naastest/naas-platform/blob/main/docs/onboarding.md) for the full label schema.

## Deploying Applications

Add ArgoCD `Application` manifests under `apps/{service-name}/`. The platform's AppProject for the `payments` team scopes deployments to `payments-*` namespaces only.
