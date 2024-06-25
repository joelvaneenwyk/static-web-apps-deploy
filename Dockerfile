# syntax=docker/dockerfile

# We pick 'bullseye' as the base image because it is the same version
# of Debian used by 'mcr.microsoft.com/appsvc/staticappsclient:stable'
ARG GOLANG_VERSION=1.22-bullseye
FROM golang:${GOLANG_VERSION} AS golang-binary

FROM mcr.microsoft.com/appsvc/staticappsclient:stable AS static-app-client
COPY --from=golang-binary /usr/local/go/ /usr/local/go/

SHELL [ "bash", "--verbose", "--login", "-c" ]
RUN apt-get update \
        && apt-get install --yes --no-install-recommends \
        bash build-essential procps curl file git ruby-full locales \
        && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN useradd -m -s /bin/bash linuxbrew && \
        echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

USER linuxbrew
ENV BREW_EXE="/home/linuxbrew/.linuxbrew/bin/brew"
RUN HOMEBREW_NO_ANALYTICS=1 NONINTERACTIVE=1 \
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN set -eax && eval "$("${BREW_EXE}" shellenv)" && brew update

USER root
ENV HOME="/root"
ENV FNM_DIR="${HOME}/.fnm"
ENV FNM_EXE="${FNM_DIR}/fnm"
ENV NODE_VERSION=20
ENV NONINTERACTIVE=1
ENV HOMEBREW_NO_ANALYTICS=1
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
ENV BREW_EXE="/home/linuxbrew/.linuxbrew/bin/brew"

RUN touch "$HOME/.bashrc" && (echo; echo 'eval "$("${BREW_EXE}" shellenv)"') >> "$HOME/.bashrc"
#RUN touch "$HOME/.bash_profile" \
#        && /home/linuxbrew/.linuxbrew/Homebrew/bin/brew shellenv >>"$HOME/.bash_profile"

# RUN brew update --debug --force
# RUN chmod -R go-w "$(brew --prefix)/share/zsh"

# install Hugo
RUN brew install hugo \
        && hugo version \
        && brew cleanup --prune=all

# install sass
RUN brew install sass/sass/sass \
        && sass --embedded --version \
        && brew cleanup --prune=all

# install fnm (Fast Node Manager)
RUN (curl -fsSL "https://fnm.vercel.app/install" | \
        bash --login -s -- --install-dir "${FNM_DIR}" --skip-shell) \
        && ( \
        "${FNM_EXE}" env --shell bash \
        && echo 'export PATH="$PATH":~/.fnm:~/.local/share/fnm' \
        ) >> "${HOME}/.bash_profile"

# download and install Node.js
RUN fnm install --lts

COPY --chmod=a+x ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
SHELL [ "bash" ]
CMD [ "bash", "--login", "-c" ]
