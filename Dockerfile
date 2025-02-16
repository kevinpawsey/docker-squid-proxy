FROM debian:sid-slim

RUN ln -sf /bin/bash /bin/sh

#RUN echo 'deb http://deb.debian.org/debian sid-backports main' > /etc/apt/sources.list.d/backports.list
#RUN echo 'deb-src http://deb.debian.org/debian sid-backports main' >> /etc/apt/sources.list.d/deb-sources.list
RUN echo 'deb-src http://deb.debian.org/debian sid main' >> /etc/apt/sources.list.d/deb-sources.list

RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	nice -n19 apt-get install -y locales && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
	apt-get clean && apt-get autoclean && \
	rm -rf /var/lib/apt/lists/*
	
RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	nice -n19 apt-get dist-upgrade -y && \
	apt-get clean && apt-get autoclean && \
	rm -rf /var/lib/apt/lists/*
	
ENV LANG en_US.utf8
ENV PATH="${PATH}:/xbin"
ENV TZ Europe/London
ENV PROXY_UID 13
ENV PROXY_GID 13

RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	nice -n19 apt-get install -y tzdata busybox openssl squid python2 && \
	mkdir /xbin && /bin/busybox --install -s /xbin && \
	apt-get clean && apt-get autoclean && \
	rm -rf /var/lib/apt/lists/*

RUN mv /etc/squid /etc/squid.dist && \
	sed -i 's/^#http_access allow localnet/http_access allow localnet/g' /etc/squid.dist/conf.d/debian.conf && \
	mkdir /etc/squid
	

COPY ssl-selfsigned.conf /etc/squid.dist/ssl-selfsigned.conf
COPY ssl.conf /etc/squid.dist/conf.d/ssl.conf	
COPY start-squid.sh /bin/start-squid.sh

VOLUME /etc/squid
VOLUME /var/log/squid
VOLUME /var/spool/squid

EXPOSE 3128/tcp
EXPOSE 3129/tcp

ENTRYPOINT ["/bin/start-squid.sh"]
