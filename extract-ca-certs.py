#!/usr/bin/env python3

import os
import re
import sys
import ssl
import socket
import base64
import getpass
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes, serialization
from ldap3 import Server, Connection, ALL, SIMPLE, Tls
import dns.resolver

stdout = sys.stdout
sys.stdout = sys.stderr

def get_domains():
    domains = {}
    for domain in sys.argv[1:]:
        domains[domain] = 1
    try:
        with open("/etc/resolv.conf") as f:
            for line in f:
                if line.startswith("search") or line.startswith("domain"):
                    parts = line.strip().split()
                    for domain in parts[1:]:
                        domains[domain] = 1
    except Exception:
        pass
    return domains.keys()

def get_dcs():
    result = []
    for domain in get_domains():
        print(f"# Searching {domain} for DC")
        query = f"_ldap._tcp.dc._msdcs.{domain}"
        try:
            answers = dns.resolver.resolve(query, 'SRV')
            dc = sorted(answers, key=lambda r: (r.priority, -r.weight))[0]
            dc = str(dc.target).rstrip('.')
            print(f"# Found DC {dc}")
            result.append(dc)
        except:
            pass
    return result

def confirm_certificate(dc_host):
    context = ssl.create_default_context()
    context.check_hostname = False
    context.verify_mode = ssl.CERT_NONE

    try:
        with context.wrap_socket(socket.socket(), server_hostname=dc_host) as sock:
            sock.connect((dc_host, 636))
            der_cert = sock.getpeercert(binary_form=True)
            cert = x509.load_der_x509_certificate(der_cert)
            thumbprint = cert.fingerprint(hashes.SHA256()).hex().upper()
            print(f"\n! Certificate presented by {dc_host}:")
            print(f"  Thumbprint: {thumbprint}")
            ok = input("\n  Do you trust this certificate? [y/N]: ").strip().lower()
            return der_cert if ok == 'y' else None
    except Exception as e:
        print(f"# Failed to retrieve certificate from {dc_host}: {e}")
        return None

def make_tls_from_der_certs(der_certs, dc_host):
    """Build Tls object with in-memory trusted PEM certs."""
    pem_data = b''.join([
        x509.load_der_x509_certificate(der).public_bytes(serialization.Encoding.PEM)
        for der in der_certs
    ])
    return Tls(validate=ssl.CERT_REQUIRED, sni=dc_host)

def extract_certificates(dc_host, username, password):
    der_cert = confirm_certificate(dc_host)
    if not der_cert:
        print(f"# Skipping {dc_host} due to untrusted certificate")
        return

    tls = make_tls_from_der_certs([der_cert], dc_host)
    server = Server(dc_host, port=636, use_ssl=True, get_info=ALL, tls=tls)

    try:
        conn = Connection(server, user=username, password=password, authentication=SIMPLE, auto_bind=True)
    except Exception as e:
        print(f"# Failed to bind to {dc_host} as {username}: {e}")
        return

    config_nc = server.info.other.get('configurationNamingContext', [None])[0]
    if not config_nc:
        print(f"# Could not determine configurationNamingContext for {dc_host}")
        return

    conn.search(config_nc, '(objectClass=certificationAuthority)', attributes=['cACertificate'])
    entries = conn.entries
    seen = set()

    for entry in entries:
        raw_certs = entry['cACertificate'].raw_values
        for i, raw_bytes in enumerate(raw_certs):
            try:
                cert = x509.load_der_x509_certificate(raw_bytes, default_backend())
            except Exception as e:
                print(f"# Failed to parse certificate from {dc_host}: {e}")
                continue

            thumbprint = cert.fingerprint(cert.signature_hash_algorithm).hex().upper()
            subject = cert.subject.rfc4514_string()
            issuer = cert.issuer.rfc4514_string()

            if thumbprint in seen or subject != issuer:
                continue
            seen.add(thumbprint)

            pem = cert.public_bytes(encoding=serialization.Encoding.PEM).decode("ascii")
            print(f"# Subject: {subject}", file=stdout)
            print(pem, file=stdout)

def main():
    username = ""
    password = ""
    for dc in get_dcs():
        if not username:
            username = input("Username (e.g. user@domain or DOMAIN\\user): ")
            password = getpass.getpass("Password: ")
        extract_certificates(dc, username, password)

if __name__ == "__main__":
    main()
