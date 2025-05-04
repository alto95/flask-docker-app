# Use official NGINX image
FROM nginx:alpine

# Remove default static files
RUN rm -rf /usr/share/nginx/html/*

# Copy your static files (like index.html)
COPY . /usr/share/nginx/html

EXPOSE 80
