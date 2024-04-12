FROM mcr.microsoft.com/appsvc/staticappsclient:stable

ARG GOLANG_VERSION
COPY --from=golang:${GOLANG_VERSION:-1.20} /usr/local/go/ /usr/local/go/

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
