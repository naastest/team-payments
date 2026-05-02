# Deploying Raw Kubernetes Resources

Use `apps/raw/{env}/` when you need to deploy Kubernetes resources that don't fit
the standard Helm service chart — CronJobs, Jobs, ConfigMaps, NetworkPolicies,
ServiceAccounts, RBAC, etc.

For deployable services (Deployment + Service + HPA + Ingress), use
[`apps/helm/{env}/`](./deploying-helm-apps.md) instead.

---

## Directory layout

```
apps/
  raw/
    dev/
      <namespace>/          ← one folder per target namespace
        resource-a.yaml
        resource-b.yaml
        subdir/             ← subdirectories are also picked up
          resource-c.yaml
    test/
      <namespace>/
        ...
    acceptance/
      <namespace>/
        ...
    production/
      <namespace>/
        ...
```

Each folder under `apps/raw/{env}/` becomes one ArgoCD Application named
`raw-payments-<namespace>-{env}`. Every `.yaml` file inside (recursively) is
deployed into the namespace whose name matches the folder name.

---

## Step-by-step: adding a new namespace + raw resources

### 1. Declare the namespace

Add a `Namespace` manifest to `namespaces/{env}/`. It must carry all required
`naas.io/*` labels and the `naas.io/owner-email` annotation — Kyverno blocks
creation without them.

```yaml
# namespaces/dev/payments-jobs.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: payments-jobs          # must match the folder name in apps/raw/dev/
  labels:
    naas.io/team: payments
    naas.io/env: dev
    naas.io/tier: backend      # backend | frontend | data | infra
    naas.io/app: payments-jobs
    naas.io/cost-center: fin-123
    naas.io/compliance: standard   # standard | pci | hipaa
  annotations:
    naas.io/owner-email: payments-team@example.com
    naas.io/description: "Short description of what lives here"
    naas.io/jira-ticket: PLAT-XXXX
```

> The namespace name **must** start with `payments-` — the AppProject restricts
> the payments team to `payments-*` namespaces. Any other prefix will be rejected
> by ArgoCD.

### 2. Create the resource folder

Create `apps/raw/dev/<namespace-name>/` and add your manifests:

```yaml
# apps/raw/dev/payments-jobs/invoice-cleanup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: invoice-cleanup
  namespace: payments-jobs     # must match the folder name
  labels:
    naas.io/team: payments
    naas.io/env: dev
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
          containers:
            - name: cleanup
              image: your-image:1.2.3
              resources:
                requests:
                  cpu: 50m
                  memory: 64Mi
                limits:
                  cpu: 200m
                  memory: 128Mi
              securityContext:
                allowPrivilegeEscalation: false
                capabilities:
                  drop: ["ALL"]
```

### 3. Open a PR and merge

ArgoCD picks up the new Application within ~2 minutes of merge. The namespace is
created first (via the `namespaces/` ApplicationSet), then the raw resources sync
into it.

---

## Kyverno requirements

All pods (including Job/CronJob pods) must satisfy:

| Policy | Requirement |
|--------|-------------|
| `no-root-containers` | `runAsNonRoot: true` |
| `no-privilege-escalation` | `allowPrivilegeEscalation: false` |
| `require-resource-limits` | `resources.requests` and `resources.limits` set |
| `restrict-hostpath` | No `hostPath` volumes |

Non-pod resources (ConfigMap, NetworkPolicy, etc.) have no extra restrictions
beyond the namespace label requirement.

---

## What goes in `apps/raw/` vs `apps/helm/`

| Use `apps/raw/` for | Use `apps/helm/` for |
|---------------------|----------------------|
| CronJob, Job | Deployment + Service |
| ConfigMap, Secret | Services that need HPA |
| NetworkPolicy | Services that need an Ingress |
| ServiceAccount, RBAC | PR preview environments |
| One-off or operational resources | Long-running application workloads |

---

## Example: multiple resource types in one namespace

You can group related resources in subdirectories for clarity:

```
apps/raw/dev/payments-jobs/
  cronjobs/
    invoice-cleanup.yaml
    statement-generator.yaml
  configmaps/
    job-config.yaml
  serviceaccounts/
    jobs-runner.yaml
```

All files are deployed into the `payments-jobs` namespace regardless of
subdirectory depth.
