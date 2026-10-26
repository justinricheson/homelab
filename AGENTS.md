# Repository guidance

## Kubernetes upgrades (`k0s-cluster`)

- Use `k0s-cluster/install.sh` to determine component order. For a single-component upgrade, update that component's files and run its `install.sh`; do not deploy it with direct `helm upgrade` commands or run the full cluster installer unnecessarily.
- Read the component's current install script, values, templates, and relevant upstream release notes before changing a pin. Check both the latest chart and the application/image version: chart `version`, `appVersion`, and the actual image tag can differ.
- Prefer official project documentation, release notes, and registries when checking versions or breaking changes. Preserve the existing comment that explains how to find newer versions when editing a version pin.
- Pin an image separately when the chart default is floating or does not select the intended application version. Avoid redundant image pins when a pinned chart selects an exact `appVersion` by default.
- If the deployed component already matches the latest suitable version, verify its pod is healthy and report that no deployment is needed.
- Preserve each component's prep/post steps and local templates. In particular, keep the Frigate `prep/files/webpush.py` JRICHESON patch when refreshing the upstream file; make the patch minimal and comment out the original lines in the established style.

## Persistent workloads and rollouts

- Before a major upgrade that migrates persistent application data, check the PVC is bound and its Longhorn volume is healthy with a recent completed backup. Frigate's config/media volumes are intentionally ephemeral in this cluster and do not need backups.
- For a single-replica workload using a ReadWriteOnce PVC, avoid a rolling update that requires the old and new pods to overlap. Use `Recreate` or a valid zero-surge/one-unavailable strategy so the old pod releases the volume first. Keep this strategy in the component's values so later upgrades work too.
- Do not create ad hoc backups or backup jobs as part of an upgrade unless the user asks.

## Deployment checks and secrets

- After running the component installer, verify the Helm release, expected image, pod readiness/restarts, and relevant PVC or service state. For Tailscale, also verify the daemon is connected and the configured subnet route remains advertised.
- Never print or include values from `secrets.yaml`, Kubernetes Secrets, authentication tokens, or password files in command output or summaries. Filter status output to the fields needed for the check.
- Do not add or run tests for version-only deployment changes unless the user asks.
