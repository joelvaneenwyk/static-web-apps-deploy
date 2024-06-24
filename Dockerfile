# syntax=docker/dockerfile:1

ARG GOLANG_VERSION=1.22.2
FROM golang:${GOLANG_VERSION} AS golang-binary

FROM mcr.microsoft.com/appsvc/staticappsclient:stable AS static-app-client
COPY --chmod=a+x ./entrypoint.sh /entrypoint.sh

COPY --from=golang-binary /usr/local/go/ /usr/local/go/

SHELL [ "bash", "--login", "-c" ]

ENV HOME="/root"
ENV FNM_DIR="${HOME}/.fnm"
ENV FNM_EXE="${FNM_DIR}/fnm"
ENV NODE_VERSION=20
ENV NONINTERACTIVE=1

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        bash build-essential procps curl file git sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install fnm (Fast Node Manager)
RUN set -o pipefail && (curl -fsSL "https://fnm.vercel.app/install" | \
        bash --login -s -- --install-dir "${FNM_DIR}" --skip-shell) \
    && ( \
        "${FNM_EXE}" env --shell bash \
        && echo 'export PATH="$PATH":~/.fnm:~/.local/share/fnm' \
    ) >> "${HOME}/.bash_profile"

# download and install Node.js
RUN fnm install --lts

# install brew
RUN bash --login -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && (echo; echo 'export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"' >> "${HOME}/.bash_profile") \
    && /home/linuxbrew/.linuxbrew/bin/brew cleanup --prune=all

# install Hugo
RUN brew install hugo \
    && hugo version \
    && brew cleanup --prune=all

# install sass
RUN brew install sass/sass/sass \
    && sass --embedded --version \
    && brew cleanup --prune=all

ENTRYPOINT ["/entrypoint.sh"]
SHELL [ "sh" ]
CMD [ "sh", "-c" ]
