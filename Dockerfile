# Simple Dockerfile to serve static frontend via nginx
FROM nginx:stable-alpine

# Remove default static content and copy your frontend folder
RUN rm -rf /usr/share/nginx/html/*
COPY ./frontend /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
