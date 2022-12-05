FROM python:latest
COPY requirements.txt /tmp/requirements
ENV TZ=Asia/Yekaterinburg
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone; \
    apt-get -y update && apt-get -y install nano mc curl iputils-ping && apt-get clean all; \
    pip install --upgrade pip; \
    pip install -qr /tmp/requirements; \
    useradd cosco -u 1001 -m -s /bin/bash; echo
USER cosco
CMD ["python"]
