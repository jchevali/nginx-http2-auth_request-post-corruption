FROM debian:stretch

RUN apt-get update
RUN apt-get install -y nghttp2=1.16.0-1 curl openssl gnupg tcpdump

RUN curl -sS https://nginx.org/keys/nginx_signing.key | apt-key add -

RUN echo "deb http://nginx.org/packages/debian/ jessie nginx" >/etc/apt/sources.list.d/nginx.list
RUN apt-get update
RUN apt-get install -y nginx

RUN mkdir -p /etc/nginx/certificates
RUN openssl req -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout /etc/nginx/certificates/test.key -out /etc/nginx/certificates/test.pem -subj /CN=test.local

ADD nginx.conf /etc/nginx/nginx.conf

ADD test.sh /test.sh
RUN chmod +x /test.sh

CMD /test.sh
