from daocloud.io/python:2.7
RUN pip install --upgrade pip
RUN pip install tornado
COPY requirements.txt /
RUN pip install -r /requirements.txt
RUN mkdir /app
WORKDIR /app

RUN pip install supervisor
RUN echo_supervisord_conf > supervisord.conf && \
    echo "[include]" >> supervisord.conf && \
    echo "files = /etc/supervisord.d/*.ini" >> supervisord.conf
RUN mv supervisord.conf /etc/
COPY tornado.ini /etc/supervisord.d/
ONBUILD COPY run.sh /

EXPOSE 9021 
#CMD ["python", "-m", "tornado.autoreload", "server.py"]

# other operation for the specific app
RUN apt-get update
# RUN apt-get install -y libmysqld-dev
RUN apt-get install -y libpq-dev python-dev
COPY requirements-others.txt /
RUN pip install -v -r /requirements-others.txt
# 时区
RUN cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

ENV THRIFT_VERSION 0.9.3

RUN buildDeps=" \
        automake \
        bison \
        curl \
        flex \
        g++ \
        libboost-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-test-dev \
        libevent-dev \
        libssl-dev \
        libtool \
        make \
        pkg-config \
    "; \
    apt-get update && apt-get install -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
    && curl -sSL "http://apache.mirrors.spacedump.net/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz" -o thrift.tar.gz \
    && mkdir -p /usr/src/thrift \
    && tar zxf thrift.tar.gz -C /usr/src/thrift --strip-components=1 \
    && rm thrift.tar.gz \
    && cd /usr/src/thrift \
    && ./configure  --without-python --without-cpp \
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/thrift \
    && curl -k -sSL "https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz" -o go.tar.gz \
    && tar xzf go.tar.gz \
    && rm go.tar.gz \
    && cp go/bin/gofmt /usr/bin/gofmt \
    && rm -rf go \
    && apt-get purge -y --auto-remove $buildDeps

# CMD [ "thrift" ]

ONBUILD ENTRYPOINT ["/run.sh"]
ONBUILD CMD ["bash", "-c"]
