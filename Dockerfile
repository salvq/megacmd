FROM debian:buster-slim

LABEL maintainer="rastislav.potocny@outlook.com"

RUN apt-get update && \
    apt-get install curl gnupg2 -y

RUN curl -k https://mega.nz/linux/repo/Debian_10.0/amd64/megacmd_1.5.0-12.1_amd64.deb --output /megacmd.deb && \
    apt install /megacmd.deb -y && \
    rm -rf /megacmd.deb && \
    apt-get remove -y curl && \
    apt-get clean

COPY /entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT bash ./entrypoint.sh
CMD /bin/bash
