#!/usr/bin/env bash

set -e

DHPARAMS_FOLDER=/etc/nginx/dhparams
DHPARAMS=${DHPARAMS_FOLDER}/dhparams.pem
CERTIFICATES_FOLDER=/etc/letsencrypt/live/${MACHINE_NAME}
CERTIFICATES_FULLCHAIN=${CERTIFICATES_FOLDER}/fullchain.pem

cat >/etc/nginx/sites-available/default.conf <<EOF
server {
   listen 80;
   server_name _;
   rewrite ^/(.*) https://${MACHINE_NAME}/\$1 permanent;
}
EOF

cat >/etc/nginx/sites-available/secure.conf <<EOF
server {
   listen 443 ssl;
   server_name _;
   ssl_certificate ${CERTIFICATES_FULLCHAIN};
   ssl_certificate_key ${CERTIFICATES_FOLDER}/privkey.pem;
   ssl_dhparam ${DHPARAMS};
   ssl_session_cache shared:SSL:20m;
 location / {
       proxy_pass http://localhost:8080;
       proxy_set_header Host      \$host;
       proxy_set_header X-Real-IP \$remote_addr;
   }
}
EOF

pushd /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/default.conf
ln -s /etc/nginx/sites-available/secure.conf
popd

cat /etc/nginx/sites-available/default.conf
cat /etc/nginx/sites-available/secure.conf

if [ ! -f ${DHPARAMS} ]; then
	openssl dhparam -out ${DHPARAMS} 2048
fi

set +e

echo "Creating or renewing ssl certificates if necessary"
certbot certonly --no-eff-email -n -a standalone --agree-tos --email admin@${MACHINE_NAME} -d ${MACHINE_NAME} --keep

set -e

if [ -f /app/init.sh ]; then
	/app/init.sh
fi

exec /usr/bin/supervisord --configuration /etc/supervisord.conf
