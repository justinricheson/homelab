# homelab

Docs and Helm charts for setting up homelab.

# Install

- Push technitium, etc
  - `install.sh`
    - Note: on this error, try again. Sometimes the webhook takes a few seconds to install.
      - ```bash
      * Internal error occurred: failed calling webhook "ipaddresspoolvalidationwebhook.metallb.io": failed to call webhook: Post "https://metallb-webhook-service.metallb-system.svc:443/validate-metallb-io-v1beta1-ipaddresspool?timeout=10s": dial tcp 10.101.89.12:443: i/o timeout
      ```
- Setup users
  - technitium
  - frigate
- Restore settings
  - technitium