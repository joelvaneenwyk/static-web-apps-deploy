# syntax=docker/dockerfile:1

ARG GOLANG_VERSION
ARG GOLANG_PATH="golang:${GOLANG_VERSION:-1.22.2}"

# hadolint ignore=DL3006
FROM $GOLANG_PATH as golang

FROM mcr.microsoft.com/appsvc/staticappsclient:stable as final

COPY --from=golang /usr/local/go/ /usr/local/go/

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
