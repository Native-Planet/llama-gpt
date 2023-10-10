FROM ghcr.io/abetlen/llama-cpp-python:latest@sha256:67ea538662ccb6262e965802c27dcb71ac6253f1da424700bd8a512e40a547e3
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir cython numpy mmh3 requests
RUN git clone https://github.com/boisgera/bitstream.git /bitstream && \
    cd /bitstream && \
    python3 setup.py --cython install
WORKDIR /api
COPY ./api/run.sh /api
CMD ["/bin/sh","/api/run.sh"]
