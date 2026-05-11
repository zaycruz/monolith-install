# monolith-install

Static Vercel project serving the Monolith CLI installer and wheel downloads at **install.thisismonolith.com**.

## What this serves

- `/install.sh` — CLI installer script (also served at `/` via rewrite)
- `/downloads/*.whl` — Python wheel artifacts for the Monolith CLI

## Usage

```sh
curl -fsSL https://install.thisismonolith.com/install.sh | sh
```

## Deploying

Push to the `main` branch. Vercel auto-deploys.

To add a new wheel version, drop the `.whl` file into `public/downloads/` and update the `DEFAULT_PACKAGE` version in `public/install.sh`.

## Domain

The Vercel project domain is `install.thisismonolith.com`. DNS is a CNAME to `cname.vercel-dns.com` configured in the `thisismonolith.com` DNS zone.

## Future

- `thisismonolith.sh` is reserved as a future short-domain alias for the installer (domain available, not yet registered).
