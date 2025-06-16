# Stage 1: Build the xdelta-wasm project
FROM alpine:3.22.0 AS build

# Install git in the Alpine container
RUN apk add --no-cache git

# Set the working directory
WORKDIR /app

# Clone the xdelta-wasm repository from the gh-pages branch
RUN git clone --branch gh-pages --single-branch https://github.com/kotcrab/xdelta-wasm.git .

# Stage 2: Set up Nginx to serve the built project
FROM nginx:stable-alpine3.21

# Copy the custom Nginx configuration for root redirects
COPY default.conf /etc/nginx/conf.d/

# Copy the built project from the build stage
COPY --from=build /app /usr/share/nginx/html/xdelta-wasm/

# Set the Nginx listen port environment variable
ENV NGINX_LISTEN_PORT 80

# Expose port 80 for external access
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

