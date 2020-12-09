FROM alpine:edge
RUN apk add --no-cache poppler-utils make ruby \
&& apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing py3-unoconv \
&& gem install pry
VOLUME /volume
WORKDIR /volume
ENTRYPOINT sh
