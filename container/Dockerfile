FROM amazonlinux:latest
COPY . /src
RUN yum -y update
RUN yum install -y python3.7
RUN pip3 install -r /src/requirements.txt
CMD ["python3.7", "/src/nonce_finder.py"]