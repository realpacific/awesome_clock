FROM nginx:1.16.0-alpine

COPY build/web /usr/share/nginx/html
COPY ngnix.conf /etc/nginx/conf.d/default.conf

CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && cat /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'