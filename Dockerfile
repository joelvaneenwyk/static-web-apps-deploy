FROM mcr.microsoft.com/appsvc/staticappsclient:stable
COPY --from=golang:1.20 /usr/local/go/ /usr/local/go/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
