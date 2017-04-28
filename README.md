# ACME (Let's Encrypt) with DNS challenge on platform.sh

**NOTICE:** Platform.sh launched builtin support for Let's Encrypt on April 20, 2017. So most likely you won't need this any more. Read more [on Platform.sh's blog](https://platform.sh/blog/free-ssl-certificates-for-every-project-every-environment).

[Platform.sh](https://platform.sh) previously didn't support using ACME/Let's Encrypt certificates (at least not with domain verification and automatic renewal).

This Docker image provides scripting for obtaining certificates via ACME/Let's Encrypt and uploading them to Platform.sh using their API.

This Docker image is based on [lego](https://github.com/xenolf/lego) to obtain a certificate via ACME DNS challenge and uploads the certificate to platform.sh using their commmand line client.

Necessary configuration via environment variables, .i.e.:

 * `ACME_EMAIL=me@example.com` (used for registering with Let's Encrypt)
 * `DOMAINS="example.com www.example.com"` (space separated list --
   must already be added to the project at Platform.sh)
 * `DNS_PROVIDER=dnsimple` (your DNS provider, see below for supported
   providers and additional needed configuration)
 * `PLATFORMSH_API_TOKEN=mytoken` (an APIv1 token)
 * `PLATFORMSH_PROJECT_ID=myprojectid`


You also need to provide environment variables required by the DNS provider challenge chosen:

 * cloudflare: `CLOUDFLARE_EMAIL`, `CLOUDFLARE_API_KEY`
 * digitalocean: `DO_AUTH_TOKEN`
 * dnsimple: `DNSIMPLE_EMAIL`, `DNSIMPLE_API_KEY`
 * dnsmadeeasy:	`DNSMADEEASY_API_KEY`, `DNSMADEEASY_API_SECRET`
 * gandi: `GANDI_API_KEY`
 * gcloud: `GCE_PROJECT`
 * namecheap: `NAMECHEAP_API_USER`, `NAMECHEAP_API_KEY`
 * rfc2136:	`RFC2136_TSIG_KEY`, `RFC2136_TSIG_SECRET`, `RFC2136_TSIG_ALGORITHM`, `RFC2136_NAMESERVER`
 * route53:	`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
 * dyn: `DYN_CUSTOMER_NAME`, `DYN_USER_NAME`, `DYN_PASSWORD`
 * vultr: `VULTR_API_KEY`
 * ovh: `OVH_ENDPOINT`, `OVH_APPLICATION_KEY`, `OVH_APPLICATION_SECRET`, `OVH_CONSUMER_KEY`
 * pdns: `PDNS_API_KEY`, `PDNS_API_URL`

Optional configuration via environment variables:

* `ACME_SERVER=https://acme-staging.api.letsencrypt.org/directory` (optional ACME server -- defaults to Let's Encrypts production server)
* `ACME_DAYS=30` (the number of days left on a certificate to renew it. Defaults to 30)

The container will store the certificates in `/data` so you should mount a volume to `/data`.
