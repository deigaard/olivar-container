FROM python:3.7-slim AS compile-image

RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential gcc

RUN python -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

#COPY setup.py .
#COPY myapp/ .
#RUN pip install .

FROM python:3.7-slim AS build-image
COPY --from=compile-image /opt/venv /opt/venv

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /root

CMD ['/opt/venv/bin/python']