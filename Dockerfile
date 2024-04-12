# syntax=docker/dockerfile:labs

ARG GOLANG_VERSION=1.20
ARG GOLANG_PATH=golang:$GOLANG_VERSION

FROM $GOLANG_PATH as golang

FROM mcr.microsoft.com/appsvc/staticappsclient:stable

COPY --from=golang /usr/local/go/ /usr/local/go/

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
