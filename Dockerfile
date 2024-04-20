# syntax=docker/dockerfile:1

ARG GOLANG_VERSION=1.22.2
FROM golang:${GOLANG_VERSION} as golang-binary

FROM mcr.microsoft.com/appsvc/staticappsclient:stable as static-app-client
COPY ./entrypoint.sh /entrypoint.sh

COPY --from=golang-binary /usr/local/go/ /usr/local/go/

RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
SHELL [ "sh" ]
CMD [ "sh", "-c" ]
