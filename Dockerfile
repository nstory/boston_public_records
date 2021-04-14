FROM alpine:3.13
RUN apk add --no-cache make poppler-utils ruby-full aws-cli py3-pip libreoffice bash && \
    pip install unoconv
RUN gem install pry rspec
RUN cd /usr/local/bin && wget -O - 'https://github.com/BurntSushi/xsv/releases/download/0.13.0/xsv-0.13.0-x86_64-unknown-linux-musl.tar.gz' | tar zx
VOLUME /volume
WORKDIR /volume
ENTRYPOINT sh
