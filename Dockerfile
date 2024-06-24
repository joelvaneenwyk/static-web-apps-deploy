# syntax=docker/dockerfile:1

ARG GOLANG_VERSION=1.22.2
FROM golang:${GOLANG_VERSION} AS golang-binary

FROM mcr.microsoft.com/appsvc/staticappsclient:stable AS static-app-client
COPY ./entrypoint.sh /entrypoint.sh

COPY --from=golang-binary /usr/local/go/ /usr/local/go/

# installs fnm (Fast Node Manager)
SHELL [ "bash", "--login", "-c" ]
ENV HOME="/root"
ENV FNM_DIR="${HOME}/.fnm"
ENV FNM_EXE="${FNM_DIR}/fnm"
ENV NODE_VERSION=20
RUN apt-get update \
    && apt-get install --yes bash sudo
RUN curl -fsSL https://fnm.vercel.app/install | \
    bash -s -- --install-dir "${FNM_DIR}" --skip-shell
RUN echo 'eval "$("${FNM_EXE}" env --use-on-cd --shell bash)"' >> "${HOME}/.bash_profile"

# download and install Node.js
RUN "${FNM_EXE}" install --lts

RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
SHELL [ "sh" ]
CMD [ "sh", "-c" ]
