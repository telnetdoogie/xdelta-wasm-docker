# Use an Alpine base image with Node.js
FROM node:18-alpine AS builder

# Install necessary packages for running xdelta3, xz-utils, and Emscripten
RUN apk update && apk add --no-cache \
    bash \
    build-base \
    python3 \
    git \
    cmake \
    ninja \
    wget \
    xdelta3 \
    xz \
    && rm -rf /var/cache/apk/*

# Set environment variables for Emscripten
ENV EMSDK /emsdk
ENV PATH $EMSDK:$EMSDK/upstream/emscripten:$PATH

# Step 1: Download Emscripten SDK archive
RUN wget https://github.com/emscripten-core/emsdk/archive/refs/tags/3.1.65.tar.gz

# Step 2: Extract the archive
RUN tar -xzf 3.1.65.tar.gz

# Step 3: Move the extracted folder to $EMSDK
RUN mv emsdk-3.1.65 $EMSDK

# Step 4: Change directory to $EMSDK and install the specific version
WORKDIR $EMSDK
RUN ./emsdk install 3.1.65

# Step 5: Activate the installed version
RUN ./emsdk activate 3.1.65

# Step 6: Load Emscripten environment variables (this will apply them for future commands in this Dockerfile)
RUN bash -c ". $EMSDK/emsdk_env.sh"

# Step 7: Clean up the downloaded tar.gz file
RUN rm -f /3.1.65.tar.gz

# Set working directory back to /app
WORKDIR /app

# Copy the project files into the container
COPY . .

# Install npm dependencies
RUN npm install

# Compile 
RUN npm run build

# Stage 2: Copy the build output from the first stage
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html
ENV NGINX_LISTEN_PORT 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

