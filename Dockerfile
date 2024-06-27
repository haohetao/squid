FROM ubuntu
LABEL maintainer="tao@hetao.me"

ENV SQUID_VERSION=6.10 \
    SQUID_CACHE_DIR=/var/cache/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=proxy
COPY entrypoint.sh /sbin/entrypoint.sh
RUN apt-get update && apt-get install -y psmisc curl vim iputils-ping iproute2 \
  build-essential libssl-dev openssl libxml2 libxml2-dev libexpat1 libexpat1-dev libsasl2-2 libsasl2-dev \
  libpam0g libpam0g-dev libkrb5-3 libkrb5-dev libecap3 libecap3-dev pkg-config libldap2 libldap2-dev \
  && rm -rf /var/lib/apt/lists/* \
  && curl http://www.squid-cache.org/Versions/v6/squid-${SQUID_VERSION}.tar.xz --output squid-${SQUID_VERSION}.tar.xz \
  && tar -Jxf squid-6.10.tar.xz \
  && cd squid-${SQUID_VERSION} \
  && ./configure \
  --prefix /usr \
  --libexecdir /usr/bin \
  --sysconfdir /etc/squid \
  --localstatedir /var \
  --runstatedir /run \
  --with-default-user=${SQUID_USER} \
  --with-logdir=${SQUID_LOG_DIR} \
  --with-pidfile=/var/run/squid.pid \
  --with-swapdir=${SQUID_CACHE_DIR} \
  --enable-arp-acl \
  --enable-linux-netfilter \
  --enable-linux-tproxy \
  --enable-async-io=100 \
  --enable-err-language="Simplify_Chinese" \
  --enable-translation \
  --enable-poll \
  --enable-gnuregex \
  --build=x86_64-linux-gnu \
  --disable-maintainer-mode \
  --disable-dependency-tracking \
  --disable-silent-rules \
  --enable-build-info="Ubuntu linux" \
  --with-filedescriptors=65536 \
  --with-large-files \
  --with-openssl \
  --enable-ssl \
  --enable-ssl-crtd \
  --enable-inline \
  --disable-arch-native \
  --enable-storeio=ufs,aufs,diskd,rock \
  --enable-removal-policies=lru,heap \
  --enable-delay-pools \
  --enable-cache-digests \
  --enable-follow-x-forwarded-for \
  --enable-auth-basic=DB,fake,getpwnam,LDAP,NCSA,PAM,POP3,RADIUS,SASL,SMB \
  --enable-auth-digest=file,LDAP \
  --enable-auth-negotiate=kerberos,wrapper \
  --enable-auth-ntlm=fake,SMB_LM \
  --enable-external-acl-helpers=file_userip,kerberos_ldap_group,LDAP_group,SQL_session,unix_group,wbinfo_group \
  --enable-security-cert-validators=fake \
  --enable-storeid-rewrite-helpers=file \
  --enable-url-rewrite-helpers=fake \
  --enable-eui \
  --enable-esi \
  --enable-icmp \
  --enable-zph-qos \
  --enable-ecap \
  --enable-underscore \
  && make && make install \
  && errors/alias-link.sh ln rm errors errors/aliases \
  && cp -a errors /usr/share/ \
  && cd .. && rm -rf squid-${SQUID_VERSION} && rm squid-${SQUID_VERSION}.tar.xz \
  && apt purge -y build-essential libssl-dev libxml2-dev libexpat1-dev libsasl2-dev libpam0g-dev libkrb5-dev libecap3-dev libldap2-dev \
  && apt autoremove -y \
  && chmod u+s /usr/bin/pinger \
  && chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
