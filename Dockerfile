FROM alpine:latest AS build

RUN apk add --no-cache git

WORKDIR /app

RUN git clone --branch gh-pages --single-branch https://github.com/kotcrab/xdelta-wasm.git .

FROM nginx:alpine

COPY --from=build /app /usr/share/nginx/html
ENV NGINX_LISTEN_PORT 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

