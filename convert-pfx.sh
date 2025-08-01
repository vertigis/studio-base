#!/bin/bash
set -e

rm -rf .tmp
mapfile -t web_certs < <(find certs-web -type f -name "$1*.pfx" | sort)

for web_cert in "${web_certs[@]}"; do
    base=${web_cert%.pfx}
    
    mkdir -p "$base"
    num=$(find "$base" -maxdepth 1 -name 'fullchain*.pem' | wc -l)
    num=$((num + 1))

    echo "Converting $web_cert ..."
    read -s -p "Enter password: " WEB_CERT_PASSWORD
    echo

    # This song and dance is necessary because
    # Windows enterprise CAs might not list the
    # certificate chain in the right order.
    openssl pkcs12 -in "$web_cert" -nokeys -clcerts -password "pass:$WEB_CERT_PASSWORD" \
        -out /tmp/scratch/host.crt    
    openssl pkcs12 -in "$web_cert" -nokeys -cacerts -password "pass:$WEB_CERT_PASSWORD" \
        -out /tmp/scratch/chain.crt
    openssl pkcs12 -in "$web_cert" -nocerts -noenc -password "pass:$WEB_CERT_PASSWORD" \
        -out /tmp/scratch/host.crt.key
    cat /tmp/scratch/chain.crt >> /tmp/scratch/host.crt

    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' \
        /tmp/scratch/host.crt > "$base/fullchain$now.tmp"
    cp /tmp/scratch/host.crt.key "$base/privkey$now.tmp"

    mv "$base/fullchain$now.tmp" "$base/fullchain$num.pem"
    mv "$base/privkey$now.tmp" "$base/privkey$num.pem"
done

rm -rf .tmp