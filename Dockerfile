FROM nginx:stable-alpine AS runtime

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

COPY ./frontend/ ./

EXPOSE 80
