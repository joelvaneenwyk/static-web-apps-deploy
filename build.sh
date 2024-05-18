#!/bin/bash

set -eaxu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Install Dart Sass Embedded..."

DARTSASS_VERSION=1.62.1

TMP_DIR="$(mktemp -d)"
OUT_FILE=sass_embedded-${DARTSASS_VERSION}-linux-x64.tar.gz
OUT_PATH="$TMP_DIR/$OUT_FILE"

if [ -x "$(command -v snap)" ]; then
    sudo snap install dart-sass-embedded
elif [ -x "$(command -v brew)" ]; then
    brew install sass/sass/dart-sass-embedded@1.62.1
else
    curl --output "$OUT_PATH" -LJO "https://github.com/sass/dart-sass-embedded/releases/download/${DARTSASS_VERSION}/$OUT_FILE";

    tar --overwrite -xvf "$OUT_PATH" -C "${TMP_DIR}";

    DART_SASS_DIR="${TMP_DIR}/sass_embedded"
    DART_SASS_EXE="${DART_SASS_DIR}/dart-sass-embedded"
    chmod a+x "${DART_SASS_EXE}"

    # This is in Netlify's PATH.
    if [ -e /opt/build/repo ]; then
        BIN_DIR=/opt/build/repo/node_modules/.bin
        if [ ! -d "$BIN_DIR" ]; then
            sudo mkdir -p "$BIN_DIR"
        fi
        sudo cp -f "${DART_SASS_EXE}" "$BIN_DIR/dart-sass-embedded"
    fi

    if [ -e '/usr/bin' ]; then
        sudo cp -f "${DART_SASS_EXE}" "/usr/bin/dart-sass-embedded"
    fi
fi

dart-sass-embedded --version

HUGO_VERSION=0.126.1
wget -O "${TMP_DIR}/hugo.deb" "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
sudo dpkg -i "${TMP_DIR}/hugo.deb"
hugo version

(
    echo "Building..."
    cd "${DIR}" || true
    npm install
    npm run build
)

rm -rf "${TMP_DIR}"
