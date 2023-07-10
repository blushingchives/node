docker stop public-proxy
docker rm public-proxy

docker run \
    -p 80:80 \
    --network cosmos-net \
    -d \
    --name public-proxy \
    --user root:root \
    nginx:1.18.0 \
    bash -c \
    " \
    echo \"$(cat ./nginx.conf | sed 's/\"/<>!spacing<>/g' | sed 's/\$/<>!dollar<>/g')\" > /etc/nginx/nginx.conf && \
    cat /etc/nginx/nginx.conf && \
    sed -i 's/<>!spacing<>/\"/g' /etc/nginx/nginx.conf && \
    sed -i 's/<>!dollar<>/\$/g' /etc/nginx/nginx.conf && \
    /usr/sbin/nginx \
    "