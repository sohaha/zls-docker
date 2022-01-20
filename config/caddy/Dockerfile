ARG CADDY_IMAGES

FROM ${CADDY_IMAGES}-builder AS builder

RUN go env -w GOPROXY=https://goproxy.cn,direct && xcaddy build --with github.com/caddy-dns/dnspod@latest


FROM ${CADDY_IMAGES}

WORKDIR /var/www/html

COPY --from=builder /usr/bin/caddy /usr/bin/caddy