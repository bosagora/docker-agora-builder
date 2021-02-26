# Build the packages used by agora that haven't been upstreamed yet.
FROM bpfk/pkgbuilder:latest AS Builder
ADD --chown=effortman:abuild ldc/ /build/ldc/
ADD --chown=effortman:abuild dub/ /build/dub/
RUN sudo apk update
WORKDIR /build/ldc/
RUN abuild -r
WORKDIR /build/dub/
RUN abuild -r

FROM alpine:edge
COPY --from=Builder --chown=root:root /home/effortman/.abuild/*.rsa.pub /etc/apk/keys/
COPY --from=Builder /home/effortman/packages/ /root/packages
RUN apk --no-cache add -X /root/packages/build/ ldc=1.25.0-r1 dub=1.24.1-r0 && \
    rm -rf /root/packages/
RUN apk --no-cache add build-base dtools-rdmd git libsodium-dev llvm-libunwind-dev openssl-dev sqlite-dev zlib-dev
