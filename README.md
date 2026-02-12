# Public Pool BCH Solo

Self-hosted BCH solo mining pool backend + simple UI.

## Exposed ports
- Stratum: 3563/tcp
- API: 3564/tcp
- UI: served via Umbrel app proxy

## Notes
- BCHN runs in prune mode by default (2048 MiB).
- UI proxies `/api/*` to the backend API.
