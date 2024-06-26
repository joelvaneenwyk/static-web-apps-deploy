# syntax=docker/dockerfile

# We pick 'bullseye' as the base image because it is the same version
# of Debian used by 'mcr.microsoft.com/appsvc/staticappsclient:stable'
ARG GOLANG_VERSION=1.22-bullseye
FROM golang:${GOLANG_VERSION} AS golang-binary

FROM mcr.microsoft.com/appsvc/staticappsclient:stable AS static-app-client
COPY --from=golang-binary /usr/local/go/ /usr/local/go/

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    bash build-essential procps curl wget coreutils file git locales \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN useradd -m -s /bin/bash linuxbrew && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

USER linuxbrew
ENV HOME="/home/linuxbrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
ENV BREW_EXE="/home/linuxbrew/.linuxbrew/bin/brew"
ENV NONINTERACTIVE=1
ENV HOMEBREW_NO_ANALYTICS=1

SHELL [ "bash", "--verbose", "--login", "-c" ]

RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
RUN eval "$("${BREW_EXE}" shellenv)" && brew update
RUN (touch "$HOME/.bash_profile" &>/dev/null || true) \
    && "${BREW_EXE}" shellenv | tee -a "$HOME/.bash_profile"

# install Hugo
RUN brew install hugo \
    && hugo version \
    && brew cleanup --prune=all

# install sass
RUN brew install sass/sass/sass \
    && sass --embedded --version \
    && brew cleanup --prune=all

USER root
SHELL [ "bash", "--verbose", "--login", "-c" ]

ENV HOME="/root"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
RUN (touch "$HOME/.bash_profile" &>/dev/null || true) \
    && "${BREW_EXE}" shellenv | tee -a "$HOME/.bash_profile"

# install fnm (Fast Node Manager)
ENV FNM_PATH="$HOME/.local/share/fnm"
ENV PATH="${FNM_PATH}:${PATH}"
RUN (touch "$HOME/.bash_profile" "$HOME/.bashrc" &>/dev/null || true) \
    && bash --verbose -c "$(curl -o- https://fnm.vercel.app/install)" \
    && (echo 'export PATH="$PATH":/root/.fnm:"$FNM_PATH"' | tee -a "$HOME/.bash_profile") \
    && (echo 'eval "$(fnm env)"' | tee -a "$HOME/.bash_profile")
RUN fnm install --lts
RUN npm install -g npm@latest

COPY --chmod=a+x "./src/entrypoint.sh" "/admin/entrypoint.sh"
RUN echo 'export PATH="/bin/staticsites/:/admin:/workspace:/root/build${PATH+:$PATH}"' >> "$HOME/.bash_profile"
ENTRYPOINT ["/admin/entrypoint.sh"]
SHELL [ "bash", "--login", "-c" ]
CMD [ ]
