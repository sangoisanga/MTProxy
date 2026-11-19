FROM debian:bookworm-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libssl-dev zlib1g-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . .
ARG COMMIT=unknown
RUN make -j"$(nproc)" COMMIT="${COMMIT}"

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl libssl3 zlib1g && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/objs/bin/mtproto-proxy /usr/local/bin/mtproto-proxy
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
WORKDIR /data
EXPOSE 443
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
