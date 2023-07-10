docker stop public-proxy
docker rm public-proxy

docker run \
    -p 80:80 \
    --network cosmos-net \
    -d \
    --name public-proxy \
    --user root:root \
    nginx:1.25.1 \
    bash -c \
    " \
    echo \"$(cat ./nginx.conf)\" > /etc/nginx/nginx.conf && \
    /usr/sbin/nginx \
    "