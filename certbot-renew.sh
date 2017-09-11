#!/bin/bash

set -e

/usr/bin/certbot renew --pre-hook="/usr/bin/supervisorctl stop nginx" --post-hook="/usr/bin/supervisorctl start nginx"