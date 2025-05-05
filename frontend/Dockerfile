# Use official NGINX image
FROM nginx:alpine

# Remove default static files
RUN rm -rf /usr/share/nginx/html/*

# Copy all  frontend files
COPY . /usr/share/nginx/html

# Overwrite default NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
