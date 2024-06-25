# syntax=docker/dockerfile

# We pick 'bullseye' as the base image because it is the same version
# of Debian used by 'mcr.microsoft.com/appsvc/staticappsclient:stable'
ARG GOLANG_VERSION=1.22-bullseye
FROM golang:${GOLANG_VERSION} AS golang-binary

FROM mcr.microsoft.com/appsvc/staticappsclient:stable AS static-app-client
COPY --chmod=a+x ./entrypoint.sh /entrypoint.sh
COPY --from=golang-binary /usr/local/go/ /usr/local/go/

RUN apt-get update \
        && apt-get install --yes --no-install-recommends \
        bash build-essential procps curl file git sudo \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

SHELL [ "bash", "--login", "-c" ]
ENV HOME="/root"
ENV FNM_DIR="${HOME}/.fnm"
ENV FNM_EXE="${FNM_DIR}/fnm"
ENV NODE_VERSION=20
ENV NONINTERACTIVE=1

# install brew
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
RUN rm -rf /home/linuxbrew/.linuxbrew/Homebrew \
        && mkdir -p /home/linuxbrew/.linuxbrew \
        && git clone "https://github.com/Homebrew/brew" "/home/linuxbrew/.linuxbrew/Homebrew" \
        && ln -s /home/linuxbrew/.linuxbrew/Homebrew/bin/brew /bin/brew

RUN touch "$HOME/.bash_profile" \
        && /home/linuxbrew/.linuxbrew/Homebrew/bin/brew shellenv --use-on-cd >>"$HOME/.bash_profile"

RUN brew update --debug --force
RUN chmod -R go-w "$(brew --prefix)/share/zsh"

# install Hugo
RUN brew install hugo \
        && hugo version \
        && brew cleanup --prune=all

# install sass
RUN brew install sass/sass/sass \
        && sass --embedded --version \
        && brew cleanup --prune=all

# install fnm (Fast Node Manager)
RUN (set -o pipefail && curl -fsSL "https://fnm.vercel.app/install" | \
        bash --login -s -- --install-dir "${FNM_DIR}" --skip-shell) \
        && ( \
        "${FNM_EXE}" env --shell bash \
        && echo 'export PATH="$PATH":~/.fnm:~/.local/share/fnm' \
        ) >> "${HOME}/.bash_profile"

# download and install Node.js
RUN fnm install --lts

ENTRYPOINT ["/entrypoint.sh"]
SHELL [ "bash" ]
CMD [ "bash", "--login", "-c" ]
