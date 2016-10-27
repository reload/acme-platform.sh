# Let's Encrypt with DNS challenge on platform.sh

[Platform.sh](https://platform.sh) currently doesn't support using
Let's Encrypt certificates (at least not with domain verification and
automatic renewal).

This image uses [lego](https://github.com/xenolf/lego) to obtain a
certificate via Let's Encrypts DNS challenge and uploads the
certificate to platform.sh using their commmand line client.

Experimental. YMMV.

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

* `ACME_SERVER=https://acme-staging.api.letsencrypt.org/directory`
(optional ACME server -- defaults to Let's Encrypts production server)
* `ACME_DAYS=30` (the number of days left on a certificate to renew
it. Defaults to 30)
```

The container will store the certificates in `/data` so you should
mount a volume to `/data`.
