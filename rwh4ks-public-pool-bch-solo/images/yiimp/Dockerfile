FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
ca-certificates curl git \
nginx php-fpm php-mysql php-gd php-curl php-mbstring php-xml php-zip php-bcmath \
build-essential cmake pkg-config \
libssl-dev libcurl4-openssl-dev libjansson-dev \
&& rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN git clone https://github.com/tpruvot/yiimp.git
RUN rm -f /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 3433
COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
