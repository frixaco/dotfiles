FROM ubuntu:22.04
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y
RUN apt install -y software-properties-common
RUN add-apt-repository --yes --update ppa:ansible/ansible
RUN apt install -y build-essential curl ansible git

# RUN apt-get update && \
#     apt-get install -y -q --allow-unauthenticated \
#     git \
#     sudo
RUN useradd -m -s /bin/zsh linuxbrew && \
    usermod -aG sudo linuxbrew &&  \
    mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R linuxbrew: /home/linuxbrew/.linuxbrew
USER linuxbrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

USER root
RUN chown -R $CONTAINER_USER: /home/linuxbrew/.linuxbrew

ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# RUN addgroup --gid 1000 frixaco
# RUN adduser --gecos frixaco --uid 1000 --gid 1000 --disabled-password frixaco
# RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
# /etc/sudoers
# USER frixaco
# WORKDIR /home/frixaco

COPY . .
RUN ansible-playbook main.yml
