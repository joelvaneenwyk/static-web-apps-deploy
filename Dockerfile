ARG GOLANG_VERSION=1.20
FROM mcr.microsoft.com/appsvc/staticappsclient:stable
COPY --from=golang:${GOLANG_VERSION} /usr/local/go/ /usr/local/go/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
