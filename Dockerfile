FROM ubuntu:bionic AS base

ENV DEBIAN_FRONTEND=noninteractive

# Updating the image
RUN apt-get update && apt-get install --no-install-recommends -y\
    tzdata \
    python3 \
    python3-dev \
    python3-venv \
    build-essential \
    awscli \
    vim \
    && rm -rf /var/lib/apt/lists/*

FROM base AS app

WORKDIR /opt/aws-auto-inventory/
COPY . .

RUN python3 --version

ENV VIRTUAL_ENV=/opt/aws-auto-inventory/.venv
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

# make init

RUN python3 -m venv ${VIRTUAL_ENV}
RUN /bin/bash -c "source ${VIRTUAL_ENV}/bin/activate" \
    && pip install --upgrade pip \
    && pip install --upgrade pyinstaller \
    && pip install -r requirements-minimal.txt

# make dist

RUN /bin/bash -c "source ${VIRTUAL_ENV}/bin/activate" \
    && pyinstaller --name aws-auto-inventory-linux-amd64 --clean --onefile --hidden-import cmath --log-level=DEBUG cli.py
