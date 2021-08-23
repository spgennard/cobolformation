FROM golang:1.17rc2-alpine3.13 as builder

RUN apk update 
ENV GNUCOBOL_VERSION="2.2"
RUN set -ex \
    && apk add --no-cache --virtual .build-deps curl \
    && apk add --no-cache --virtual .gnucobol-deps build-base gcc binutils \
    && apk add --no-cache gettext-dev gmp-dev db-dev ncurses-dev \
    && export WORKDIR=$(mktemp -d) \
    && cd "${WORKDIR}" \
    && curl -L -o "gnucobol-${GNUCOBOL_VERSION}.tar.gz" "https://sourceforge.net/projects/open-cobol/files/gnu-cobol/${GNUCOBOL_VERSION}/gnucobol-${GNUCOBOL_VERSION}.tar.gz" \
    && tar xzvf "gnucobol-${GNUCOBOL_VERSION}.tar.gz" \
    && cd "gnucobol-${GNUCOBOL_VERSION}/" \
    && ./configure \
    && make \
    && make install \
    && cd \
    && rm -R "${WORKDIR}" \
    && apk del .build-deps \
    && cobc -V \
    && apk add musl-dev

WORKDIR /cobol

COPY . .

RUN make build

ENTRYPOINT [ "/cobol/cobolformation" ]