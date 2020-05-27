FROM alpine:latest
MAINTAINER manasbellani
# ------------------------------------------------------------------------------
# Install all the apt-gettable dependencies one-by-one
# Obscure Installed packages:
#   psmisc, for  using killall
#   groff, required for awscli help page
#   npm, requred for cloudsploit-scans
#   ruby,ruby-dev,gcc,make,libc-dev needed for installing json lib for aws_public_ips ruby script
#   py-pip, installed for aws-security-benchmark script
#   sshpass, for CSSuite
#   graphviz, for principalmapper
#   bind-tools, for host dns resolution
# ------------------------------------------------------------------------------
RUN apk add \
    sudo \
    git \
    vim \
    psmisc \
    python3 \
    curl \
    bash \
    jq \
    sed \
    groff \
    ruby \
    ruby-dev \
    gcc \
    make \
    libc-dev \
    npm \
    py-pip \
    grep \
    sshpass \
    py3-virutalenv \
    autoconf \
    automake \
    libtool \
    python3-dev \
    graphviz \
    bind-tools

# ------------------------------------------------------------------------------
# Upgrade pip in python2, python3
# ------------------------------------------------------------------------------
RUN python2 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade pip

# Install packages for running AWS CLI, boto3 for AWS scripting in python
RUN python3 -m pip install requests awscli boto3 yq tk

# Install boto3 for aws-security-benchmark in python2
RUN python2 -m pip install boto3

# Install the .vimrc file                                                                           
RUN curl -s -L -k https://gist.githubusercontent.com/manasmbellani/9b9e6ab12510ccaa82aa31650a804a9d/raw/ -o /root/.vimrc

# Install the AWS Research from Rhinosecuritylabs
RUN git clone https://github.com/RhinoSecurityLabs/Cloud-Security-Research /opt/Cloud-Security-Research

# Install the aws_public_ips repo for getting a list of publicly facing IPs
RUN git clone https://github.com/arkadiyt/aws_public_ips /opt/aws_public_ips && \
    cd /opt/aws_public_ips && \
    gem install aws_public_ips && \
    gem install json

# Install cloudsploit
RUN git clone https://github.com/cloudsploit/scans /opt/cloudsploit-scans && \
    cd /opt/cloudsploit-scans && \
    npm install

# Installing aws-security-benchmark validation script
RUN git clone https://github.com/awslabs/aws-security-benchmark /opt/aws-security-benchmark

# -----------------------------------------------------------------------------
# Install pacu and its dependencies
# -----------------------------------------------------------------------------

# Do not install the original Pacu, as number of issues have been fixed in the updated pacu 
# version below.
#RUN git clone https://github.com/RhinoSecurityLabs/pacu /opt/pacu && \
#    cd pacu && \
#    bash install.sh && \
#    python3 pacu.py

# Download an updated version with better error handling
RUN git clone https://github.com/manasmbellani/pacu /opt/pacu && \
    cd pacu && \
    git remote add upstream https://github.com/RhinoSecurityLabs/pacu && \
    git pull upstream master && \
    bash install.sh

# Install nimbostratus and its dependencies
RUN git clone https://github.com/andresriancho/nimbostratus.git && \
    cd nimbostratus && \
    python2 -m pip install -r requirements.txt

# Install weirdAAL and setup the virtualenv with dependencies installed inside it
RUN git clone https://github.com/carnal0wnage/weirdAAL.git /opt/weirdAAL && \
    cd /opt/weirdAAL && \
    python3 -m virtualenv weirdAAL  && \
    source weirdAAL/bin/activate && \
    python3 -m pip install -r requirements.txt && \
    deactivate
 
# Install cloudjack
RUN git clone https://github.com/prevade/cloudjack /opt/cloudjack

# Install pmapper for AWS user/roles review
RUN python3 -m pip install principalmapper

# -----------------------------------------------------------------------------
# Install S3scan
# -----------------------------------------------------------------------------
RUN git clone https://github.com/bear/s3scan /opt/s3scan

# -----------------------------------------------------------------------------
# Install Powershell and AWS Tools, required for SkyArk
# -----------------------------------------------------------------------------
RUN apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    curl

RUN apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust

# Download the powershell '.tar.gz' archive
RUN curl -s -L https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/powershell-7.0.0-linux-alpine-x64.tar.gz -o /tmp/powershell.tar.gz

# Create the target folder where powershell will be placed
RUN sudo mkdir -p /opt/microsoft/powershell/7

# Expand powershell to the target folder
RUN tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

# Set execute permissions
RUN chmod +x /opt/microsoft/powershell/7/pwsh

# Create the symbolic link that points to pwsh
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Install AWS Tools in Powershell, required for SkyArk
RUN pwsh -c "Install-Module -Name AWS.Tools.Installer -Force"

# -----------------------------------------------------------------------------
# Clone Skyark ShadowAdmins finder repo
# -----------------------------------------------------------------------------
RUN git clone https://github.com/cyberark/SkyArk /opt/SkyArk

# -----------------------------------------------------------------------------
# Install GCP CloudBuild Exploitation Script 
# -----------------------------------------------------------------------------
RUN git clone https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation /opt/GCP-IAM-Privilege-Escalation

# -----------------------------------------------------------------------------
# Start within this shared directory
# -----------------------------------------------------------------------------
WORKDIR /opt/athena-tools

