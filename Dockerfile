FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION=3.38.8
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

# Avoid running flutter as root
RUN useradd -m flutter
USER flutter

WORKDIR /app
COPY --chown=flutter:flutter pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY --chown=flutter:flutter . .
RUN flutter build web --release

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
