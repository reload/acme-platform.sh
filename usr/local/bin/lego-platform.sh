#!/bin/bash

set +x

. /etc/container_environment.sh

TMPDIR=$(mktemp -d)

cleanup() {
    rm -rf "${TMPDIR}"
}

trap cleanup EXIT

IFS=' ' read -r -a domains <<< "${DOMAINS}"
LEGOPATH=/data
export HOME=/root
ACME_SERVER=${ACME_SERVER:-https://acme-v01.api.letsencrypt.org/directory}
ACME_DAYS=${ACME_DAYS:-30}

verify_preconditions () {
    [ ! -z "${ACME_SERVER}" ] && [ ! -z "${ACME_EMAIL}" ] && [ ! -z "${DNS_PROVIDER}" ] && verify_domains_in_platformsh
}

verify_domains_in_platformsh () {
    local status=0

    for i in "${!domains[@]}"
    do
        platform domain:get --no --project="${PLATFORMSH_PROJECT_ID}" "${domains[i]}"
        local err=$?
        status=$((${err}|${status}))
    done

    return ${status}
}

create_or_renew_domains () {
    for i in "${!domains[@]}"
    do
        if $(domain_exists "${domains[i]}")
        then
            renew_domain "${domains[i]}"
        else
            create_domain "${domains[i]}"
        fi
    done
}

domain_exists () {
    local domain=$1
    [ -e "${LEGOPATH}/certificates/${domain}.crt" ]
}

create_domain () {
    local domain=$1
    lego --domains=${domain} --server=${ACME_SERVER} --email=${ACME_EMAIL} --accept-tos --path=${LEGOPATH} --dns=${DNS_PROVIDER} run
}

renew_domain () {
    local domain=$1
    lego --domains=${domain} --server=${ACME_SERVER} --email=${ACME_EMAIL} --accept-tos --path=${LEGOPATH} --dns=${DNS_PROVIDER} renew --days=${ACME_DAYS}
}

upload_certificates () {
    for i in "${!domains[@]}"
    do
        upload_certificate "${domains[i]}"
    done
}

upload_certificate () {
    local domain=$1

    csplit -f ${TMPDIR}/cert- ${LEGOPATH}/certificates/${domain}.crt '/-----BEGIN CERTIFICATE-----/' '{*}'

    local cert=${TMPDIR}/cert-01
    local key=${LEGOPATH}/certificates/${domain}.key
    local chain=${TMPDIR}/cert-02
    local current=${TMPDIR}/current

    # Compare certificate to current certificate at platform.sh. Only upload if they are different.

    # We allow the following commands to fail because there might not be a current certificate.
    set -x
    platform domain:get --no --project="${PLATFORMSH_PROJECT_ID}" --property=ssl "${domain}" |  shyaml get-value certificate > "${current}"

    if [ "$(openssl x509 -in "${cert}"  -noout -fingerprint)" != "$(openssl x509 -in "${current}"  -noout -fingerprint)" ]; then
       platform domain:update --no --cert=${cert} --key=${key} --chain=${chain} --project="${PLATFORMSH_PROJECT_ID}" "${domain}"
    fi

    set +x
}

verify_preconditions && create_or_renew_domains && upload_certificates
