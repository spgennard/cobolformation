#-----------------------------------------------------------------------------
# Build the COBOL assets
#-----------------------------------------------------------------------------
FROM microfocus/entdevhub:ubuntu20.04_7.0_x64 as cbl-builder
WORKDIR /cobol
COPY . /cobol
RUN . ${MFPRODBASE}/bin/cobsetenv && \
    make clean cobol

#-----------------------------------------------------------------------------
# Build the golang assets
#-----------------------------------------------------------------------------
FROM ubuntu:20.04 as go-builder
ENV GOLANG_VERSION 1.17

# Install wget
RUN apt update && \
    apt install -y build-essential wget

# Install Go
RUN echo Downloading golang ${GOLANG_VERSION} && \
    wget -nv https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    echo Extracting && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    echo Cleaning up install && \
    rm -f go${GOLANG_VERSION}.linux-amd64.tar.gz

ENV PATH "$PATH:/usr/local/go/bin"

WORKDIR /cobol
COPY . /cobol
RUN make clean cobolformation

#-----------------------------------------------------------------------------
# Assemble
#-----------------------------------------------------------------------------
FROM microfocus/cobolserver:ubuntu20.04_7.0_x64
WORKDIR /cobol
COPY --from=go-builder /cobol/cobolformation /cobol/
COPY --from=cbl-builder /cobol/datatype.so /cobol/
COPY --from=cbl-builder /cobol/cobconfig /cobol/

ENV LD_LIBRARY_PATH=/cobol:.:${LD_LIBRARY_PATH}
ENV COBCONFIG=/cobol/cobconfig
ENTRYPOINT . ${MFPRODBASE}/bin/cobsetenv && \
            "./cobolformation"