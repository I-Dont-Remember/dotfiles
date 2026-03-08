FROM ubuntu:22.04

# TODO: now that we are using pure bash scripts, should we do the passwordless sudo user
# to better mock a fresh install?

# a "fresh" install as if we were a new user
RUN apt-get update && apt-get install -y curl wget apt-utils snapd gnupg apt-transport-https sudo ca-certificates \
    && apt-get -y upgrade

# Setup sudo user here to mock as if we just setup a new laptop
RUN useradd --groups sudo -ms /bin/bash kevin && echo kevin:12345 | chpasswd
# passwordless so we don't have to do any monkeying around in the container even though it's
# unsafe for real systems
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER kevin
