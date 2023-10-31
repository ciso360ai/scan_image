# Base image
FROM ubuntu:22.04

# Environment Variables
ENV DEBIAN_FRONTEND="noninteractive"
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV TLDEXTRACT_CACHE="/root/tldextract.cache"
ENV pg_timetable_ver="5.5.0"
ENV go_ver="1.21.3"

ARG TARGETARCH
ARG TARGETPLATFORM

# Install essentials
RUN apt update -y && apt install -y --no-install-recommends \
    build-essential \
    bsdmainutils \
    cmake \
    curl \
    dnsmasq \
    dnsutils \
    firefox \
    gcc \
    git \
    jq \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    libpq-dev \
    libpcap-dev \
    nano \
    nmap \
    net-tools \
    iputils-ping \
    python3 \
    python3-dev \
    python3-pip \
    python3-netaddr \
    wget \
    whois \
    x11-utils \
    xvfb \
    zlib1g-dev

RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
    && apt update -y \
    && apt autoremove -qy \
    && rm -rf /var/lib/apt/lists/*

# Download and install specific Intel versions
RUN \
  if [ "$TARGETPLATFORM" = 'linux/amd64' ]; then \
    wget https://github.com/cybertec-postgresql/pg_timetable/releases/download/v${pg_timetable_ver}/pg_timetable_${pg_timetable_ver}_Linux_x86_64.tar.gz \
    && tar -xvf pg_timetable_${pg_timetable_ver}_Linux_x86_64.tar.gz \
    && mv pg_timetable_${pg_timetable_ver}_Linux_x86_64/pg_timetable /usr/bin \
    && rm -rf pg_timetable_${pg_timetable_ver}_Linux_x86_64* \
    && wget https://go.dev/dl/go${go_ver}.linux-amd64.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf go${go_ver}.linux-amd64.tar.gz \
    && rm -rf *.tar.gz \
  ; fi

# Download and install specific ARM versions
RUN \
  if [ "$TARGETPLATFORM" = 'linux/arm64' ]; then \
    wget https://github.com/cybertec-postgresql/pg_timetable/releases/download/v${pg_timetable_ver}/pg_timetable_${pg_timetable_ver}_Linux_arm64.tar.gz \
    && tar -xvf pg_timetable_${pg_timetable_ver}_Linux_arm64.tar.gz \
    && mv pg_timetable_${pg_timetable_ver}_Linux_arm64/pg_timetable /usr/bin \
    && rm -rf pg_timetable_${pg_timetable_ver}_Linux_arm64* \
    && wget https://go.dev/dl/go${go_ver}.linux-arm64.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf go${go_ver}.linux-arm64.tar.gz \
    && rm -rf *.tar.gz \
  ; fi

ENV GOROOT="/usr/local/go"
ENV GOPATH=$HOME/go
ENV PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"

# Make directory for app
WORKDIR /tools

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN python3 -m pip install --upgrade pip \
    && pip3 install --no-cache-dir psycopg2-binary tldextract

# Download Go packages
RUN GOARCH=${TARGETARCH} go install github.com/tomnomnom/anew@latest
