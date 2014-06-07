# Docker version 0.11.1

FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y python-pip

ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt

ADD src	/src

EXPOSE 8080
CMD ["python", "/src/frontend.py"]
