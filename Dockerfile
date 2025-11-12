# Dockerfile — serve static frontend with nginx
FROM nginx:stable-alpine AS runtime

WORKDIR /usr/share/nginx/html
# Clear default content
RUN rm -rf ./*

# Copy compiled/static frontend files
COPY ./frontend/ ./

EXPOSE 80

# default CMD from nginx image is fine (nginx -g 'daemon off;')
