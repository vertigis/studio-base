FROM alpine AS tools
RUN apk add --no-cache bash python3 py3-aiohttp py3-ldap3 py3-cryptography py3-dnspython openssl
COPY ./*.py /
COPY ./*.sh /
RUN chmod +x /*.py /*.sh
RUN ln -sf /bin/bash /bin/sh
RUN ln -sf /activate.py /activate
RUN ln -sf /extract-ca-certs.py /extract-ca-certs
RUN ln -sf /convert-pfx.sh /convert-pfx
