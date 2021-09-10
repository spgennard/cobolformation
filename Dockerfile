#-----------------------------------------------------------------------------
# Build the COBOL assets
#-----------------------------------------------------------------------------
FROM microfocus/entdevhub:ubuntu20.04_7.0_x64 as cbl-builder
WORKDIR /cobol
COPY . /cobol
RUN . ${MFPRODBASE}/bin/cobsetenv && \
    make cobol

#-----------------------------------------------------------------------------
# Build the golang assets
#-----------------------------------------------------------------------------
FROM golang:1.17rc2-alpine3.13 as go-builder
WORKDIR /cobol
COPY . /cobol
RUN apk add build-base gcc binutils && \
    make cobolformation

#-----------------------------------------------------------------------------
# Assemble
#-----------------------------------------------------------------------------
FROM microfocus/cobolserver:ubuntu20.04_7.0_x64
WORKDIR /cobol
COPY --from=go-builder /cobol/cobolformation /cobol/
COPY --from=cbl-builder /cobol/datatype.so /cobol/
ENTRYPOINT [ "/cobol/cobolformation" ]