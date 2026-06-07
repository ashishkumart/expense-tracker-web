FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa wget

# Fixed: The full, correct URL to clone the Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v

WORKDIR /app

EXPOSE 8080

# Starts the local development web server inside the container
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
