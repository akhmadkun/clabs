FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV FND_CONFIG_ROOT=/etc/fnd-services
ENV SERVICE_IP=192.168.121.20
ENV SERVICE_IFACE=eth0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      chrony \
      curl \
      dnsmasq \
      dnsutils \
      ethtool \
      iproute2 \
      iputils-ping \
      jq \
      netcat-openbsd \
      nginx \
      nmap \
      openssh-server \
      openssl \
      procps \
      freeradius \
      freeradius-utils \
      rsyslog \
      snmpd \
      snmp \
      socat \
      tcpdump \
      tftpd-hpa \
      tftp-hpa \
      traceroute \
      vim-tiny \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
      /etc/fnd-services \
      /etc/fnd-services/dns \
      /etc/fnd-services/ntp \
      /etc/fnd-services/ssh \
      /etc/fnd-services/syslog \
      /etc/fnd-services/snmp \
      /etc/fnd-services/nginx \
      /etc/fnd-services/tftp \
      /etc/fnd-services/radius \
      /srv/tftp \
      /var/www/html \
      /var/log/fnd-services \
    && echo 'Palo Lab Universal Services 1.4' > /etc/fnd-services/VERSION

COPY start-services.sh /usr/local/bin/start-services.sh
COPY service-data/www/index.html /var/www/html/index.html
COPY service-data/tftp/tftp-test.txt /srv/tftp/tftp-test.txt

RUN sed -i 's/\r$//' /usr/local/bin/start-services.sh && \
    chmod +x /usr/local/bin/start-services.sh

EXPOSE 22/tcp \
       53/tcp 53/udp \
       69/udp \
       80/tcp \
       123/udp \
       161/udp \
       514/tcp 514/udp \
       1812/udp 1813/udp

CMD ["/usr/local/bin/start-services.sh"]
