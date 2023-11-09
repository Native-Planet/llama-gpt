FROM ghcr.io/abetlen/llama-cpp-python:latest@sha256:b6d21ff8c4d9baad65e1fa741a0f8c898d68735fff3f3cd777e3f0c6a1839dd4
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir cython numpy mmh3 requests
RUN pip3 install --upgrade llama-cpp-python
RUN git clone https://github.com/boisgera/bitstream.git /bitstream && \
    cd /bitstream && \
    python3 setup.py --cython install
RUN mkdir /lick
COPY ./lick/noun.py /lick
COPY ./lick/lick-ai-interface.py /lick
WORKDIR /app
COPY ./api/run.sh /app
CMD ["/bin/sh","/app/run.sh"]
