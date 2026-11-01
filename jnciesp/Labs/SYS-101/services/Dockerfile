FROM ghcr.io/srl-labs/network-multitool:latest

USER root

RUN apk add --no-cache \
        chrony \
        dnsmasq \
        freeradius \
        freeradius-utils \
        openssh-server \
        rsyslog \
        vsftpd \
        supervisor \
        shadow \
        bash \
    && adduser -D -h /home/lab lab \
    && echo 'lab:lab123' | chpasswd \
    && mkdir -p \
        /srv/ftp/archive \
        /var/log/sys101 \
        /run/chrony \
        /run/freeradius \
        /run/sshd \
    && chown -R lab:lab /srv/ftp/archive \
    && chown radius:radius /run/freeradius

COPY chrony.conf /etc/chrony/chrony.conf
COPY chrony.keys /etc/chrony/chrony.keys
COPY dnsmasq.conf /etc/dnsmasq.conf

# FreeRADIUS 3.x "files" module reads this authorize file.
COPY radius-clients.conf /etc/raddb/clients.conf
COPY radius-users /etc/raddb/mods-config/files/authorize

COPY rsyslog.conf /etc/rsyslog.conf
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY sshd_config /etc/ssh/sshd_config
COPY supervisord.conf /etc/supervisord.conf
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
COPY start-sys101.sh /usr/local/bin/start-sys101.sh

RUN chmod 600 /etc/chrony/chrony.keys \
    && chown root:radius \
        /etc/raddb/clients.conf \
        /etc/raddb/mods-config/files/authorize \
    && chmod 640 \
        /etc/raddb/clients.conf \
        /etc/raddb/mods-config/files/authorize \
    # Ensure the radius user can traverse the path to the authorize file.
    && chown root:radius \
        /etc/raddb/mods-config \
        /etc/raddb/mods-config/files \
    && chmod 750 \
        /etc/raddb/mods-config \
        /etc/raddb/mods-config/files \
    # Fail the image build immediately if FreeRADIUS cannot read the user DB.
    && su -s /bin/sh radius -c \
        'test -r /etc/raddb/mods-config/files/authorize' \
    && chmod +x \
        /usr/local/bin/healthcheck.sh \
        /usr/local/bin/start-sys101.sh \
    && ssh-keygen -A \
    # Validate the complete FreeRADIUS configuration at build time.
    && /usr/sbin/radiusd -XC

EXPOSE 21/tcp 22/tcp 53/tcp 53/udp 123/udp 1812/udp 1813/udp 514/tcp 514/udp

HEALTHCHECK --interval=20s --timeout=5s --retries=12 CMD /usr/local/bin/healthcheck.sh

CMD ["/usr/local/bin/start-sys101.sh"]
