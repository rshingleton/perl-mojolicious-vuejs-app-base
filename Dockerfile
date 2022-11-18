# This is a multi-stage build to reduce the end image size. 
# We use a compile image to install any dependencies and then just copy the
# end results to the runtime container, leaving any build assets behind 

FROM rshingleton/alpine-perl:5.36.0 AS build-image

# Some dependencies might require system packages to be installed.
# Add any system build dependencies below and uncomment 
RUN apk update && apk upgrade && apk add --no-cache \
        build-base \
        curl \
        gcc \
        gnupg \
        make \
        openssl \
        openssl-dev \
        tar \
        zlib \
        zlib-dev \
        nodejs \
        npm \
    && rm -rf /var/cache/apk/*

# make the 'app' folder the current working directory
WORKDIR /app

# copy project files and folders to the current working directory (i.e. 'app' folder)
COPY . .

# install any Perl dependencies from the cpanfile
RUN cpm install -g 

# copy both 'package.json' and 'package-lock.json' (if available)
COPY package*.json ./

# install project npm dependencies
RUN npm install

# build app for production with minification
RUN npm run build

FROM alpine:latest AS runtime-image

ENV PATH="/opt/perl/bin:${PATH}"

# Copy the base Perl installation from the build-image
COPY --from=build-image /opt/perl /opt/perl

# make the 'app' folder the current working directory
WORKDIR /app

# Copy the app installation from the build-image
COPY --from=build-image /app/mojo_vue.yml ./mojo_vue.yml
COPY --from=build-image /app/lib ./lib
COPY --from=build-image /app/script/mojo_vue ./script/mojo_vue
COPY --from=build-image /app/templates ./templates
COPY --from=build-image /app/dist ./public

EXPOSE 8080
CMD ./script/mojo_vue daemon -m production -l http://*:8080