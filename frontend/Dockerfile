# Stage 1: Build the Flutter Web application
FROM ubuntu:22.04 AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa
WORKDIR /app

# Clone Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run doctor to initialize and pre-download web artifacts
RUN flutter doctor

# Copy your frontend source code and compile
COPY . .
RUN flutter build web

# Stage 2: Serve using Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]