from daocloud.io/python:3.6
RUN pip install --upgrade pip
RUN pip install tornado
COPY requirements.txt /
RUN pip install -r /requirements.txt
RUN mkdir /app
WORKDIR /app

RUN git clone https://github.com/Supervisor/supervisor.git
RUN cd supervisor && python setup.py install
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
ONBUILD COPY requirements-others.txt /
ONBUILD RUN pip install -v -r /requirements-others.txt
# 时区
RUN cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

ONBUILD ENTRYPOINT ["/run.sh"]
ONBUILD CMD ["bash", "-c"]
