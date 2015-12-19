FROM alpine:edge

ENV JRE=jre1.8.0_60 \
    JAVA_HOME=/opt/jre

# Java 8
RUN apk add --update paxctl wget ca-certificates && \
    cd /tmp && \
    wget "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
         "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
    apk add --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
    /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    mkdir /opt && \
    wget http://www.java.net/download/jdk8u60/archive/b18/binaries/jre-8u60-ea-bin-b18-linux-x64-02_jun_2015.tar.gz -O /tmp/${JRE}.tgz && \
    cd /opt && tar zxvf /tmp/${JRE}.tgz && \
    ln -s /opt/${JRE} /opt/jre && \
    ln -s /opt/jre/bin/java /usr/bin/java && \
    paxctl -c /opt/jre/bin/java && \
    paxctl -m /opt/jre/bin/java && \
    apk del paxctl wget ca-certificates && \
    cd /opt/jre/lib/amd64 && rm libjavafx_* libjfx* libfx* && \
    cd /opt/jre/lib/ && rm -rf ext/jfxrt.jar jfxswt.jar javafx.properties font* && \
    rm /tmp/* /var/cache/apk/*

# MXML
RUN apk add --update wget libc-dev make gcc ca-certificates && \
	cd /tmp && \
	wget http://www.msweet.org/files/project3/mxml-2.9.tar.gz && \
	tar zxvf mxml-2.9.tar.gz && \
	cd mxml-2.9 && \
	./configure --prefix=/usr && \
	make install && \
	apk del wget make gcc libc-dev ca-certificates && \
	rm -rf /tmp/* /var/cache/apk/*

# libconfuse
RUN apk add --update wget libc-dev make gcc ca-certificates && \
	wget http://savannah.nongnu.org/download/confuse/confuse-2.7.tar.gz && \
	tar zxvf confuse-2.7.tar.gz && \
	cd confuse-2.7 && \
	./configure --prefix=/usr && \
	make install && \
	apk del wget make gcc libc-dev ca-certificates && \
	rm -rf /tmp/* /var/cache/apk/*

# ANTLR3
RUN apk add --update wget libc-dev make gcc ca-certificates && \
	mkdir -p /usr/share/java && \
	cd /usr/share/java && \
	wget http://www.antlr3.org/download/antlr-3.5.2-complete-no-st3.jar && \
	cd /tmp && \
	wget http://www.antlr3.org/download/C/libantlr3c-3.4.tar.gz && \
	tar xzf libantlr3c-3.4.tar.gz && \
	cd libantlr3c-3.4 && \
	./configure --enable-64bit --prefix=/usr && \
	make install && \
	cd /tmp && \
	printf "#!/bin/sh \n\
		export CLASSPATH=/usr/share/java/antlr-3.5.2-complete-no-st3.jar:\$CLASSPATH \n\
		/usr/bin/java org.antlr.Tool \$* \n\
	" > antlr3 && \
	install -m 755 antlr3 /usr/bin && \
	apk del wget make gcc libc-dev ca-certificates && \
	rm -rf /tmp/* /var/cache/apk/*

# forked-daapd
RUN apk --update add git gcc libtool gettext autoconf automake ffmpeg-dev \
	sqlite-dev avahi-dev gettext-dev libgcrypt-dev libevent-dev zlib-dev \
	gperf libc-dev libunistring-dev alsa-lib-dev make bsd-compat-headers \
	alsa-lib ffmpeg-libs sqlite-libs libunistring avahi-libs libevent \
	libgcrypt && \
	cd /tmp && \
	git clone https://github.com/ejurgensen/forked-daapd.git && \
	cd forked-daapd && \
	autoreconf -i && \
	./configure --host=x86_64-alpine-linux-musl --prefix=/usr \
		--sysconfdir=/etc --localstatedir=/var && \
	make install && \
	apk del git libtool autoconf automake make bsd-compat-headers \
		libc-dev libunistring-dev alsa-lib-dev libgcrypt-dev \
		libevent-dev zlib-dev avahi-dev && \
	rm -rf /tmp/* /var/cache/apk/*

# RIP Java
RUN rm -rf /usr/bin/antlr3 && \
	rm -rf /usr/bin/java && \
	rm -rf /opt/${JRE} /opt/jre

# Other required services
RUN apk --update add dbus avahi

COPY forked-daapd.conf /etc/forked-daapd.conf
COPY start.sh /start.sh

VOLUME [ "/media", "/db" ]

CMD [ "/start.sh" ]
