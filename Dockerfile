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
RUN apk --no-cache add -X /root/packages/build/ ldc=1.26.0-r0 dub=1.26.0-r0
# Do not delete the packages, as the runner might need to copy the runtime
# RUN rm -rf /root/packages/
RUN apk --no-cache add \
    build-base clang dtools-rdmd git libsodium-dev linux-headers llvm-libunwind-dev npm openssl-dev python3 sqlite-dev zlib-dev
