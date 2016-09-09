#!/bin/bash

set +x

. /etc/container_environment.sh

IFS=' ' read -r -a domains <<< "${DOMAINS}"
LEGOPATH=/data
export HOME=/root
SERVER=${SERVER:-https://acme-v01.api.letsencrypt.org/directory}

verify_preconditions () {
    [ ! -z "${SERVER}" ] && [ ! -z "${EMAIL}" ] && [ ! -z "${DNS_PROVIDER}" ] && verify_domains_in_platformsh
}

verify_domains_in_platformsh () {
    local status=0

    for i in "${!domains[@]}"
    do
        platform domain:get --yes --project="${PLATFORMSH_PROJECT_ID}" "${domains[i]}"
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
    lego --domains=${domain} --server=${SERVER} --email=${EMAIL} --accept-tos --path=${LEGOPATH} --dns=${DNS_PROVIDER} run
}

renew_domain () {
    local domain=$1
    lego --domains=${domain} --server=${SERVER} --email=${EMAIL} --accept-tos --path=${LEGOPATH} --dns=${DNS_PROVIDER} renew --days=60
}

upload_certificates () {
    for i in "${!domains[@]}"
    do
        upload_certificate "${domains[i]}"
    done
}

upload_certificate () {
    local domain=$1
    local cert=${LEGOPATH}/certificates/${domain}.crt
    local key=${LEGOPATH}/certificates/${domain}.key
    local chain=${LEGOPATH}/certificates/${domain}.crt
    platform domain:update --yes --cert=${cert} --key=${key} --chain=${chain} --project="${PLATFORMSH_PROJECT_ID}" "${domain}"
}

verify_preconditions && create_or_renew_domains && upload_certificates
