FROM node:lts-alpine3.18 AS base
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

COPY package.json ./

RUN apk update && \
    apk add --no-cache \
    vips-dev \
    fftw-dev \
    gcc \
    g++ \
    make \
    libc6-compat \
    && rm -rf /var/cache/apk/*

RUN yarn set version stable && \
    yarn install --production=true && \
    yarn add sharp --ignore-engines && \
    yarn cache clean

FROM base AS build
WORKDIR /usr/src/wpp-server
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

COPY package.json ./
RUN yarn install
RUN yarn cache clean
COPY . .
RUN yarn build

FROM base
WORKDIR /usr/src/wpp-server/
RUN apk add --no-cache chromium
COPY . .
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/
EXPOSE 21465
ENTRYPOINT ["node", "dist/server.js"]
