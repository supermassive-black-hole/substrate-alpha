FROM openjdk:8u141-jre-slim

ADD run.sh /app/run.sh

RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx supervisor python-pip libyaml-0-2 libyaml-dev python-dev cron python-certbot \
 && echo "deb http://packages.dotdeb.org jessie all" >>/etc/apt/sources.list \
 && echo "deb-src http://packages.dotdeb.org jessie all" >>/etc/apt/sources.list \
 && pip install awscli \
 && rm -rf /var/lib/apt/lists/* /tmp/* \
 && rm /etc/nginx/sites-enabled/default \
 && apt-get remove -y libyaml-dev python-dev \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD certbot-cron /etc/cron.d/certbot-cron
ADD nginx.conf /etc/nginx/nginx.conf
ADD supervisord.conf /etc/supervisord.conf

CMD ["/app/run.sh"]
