chain_name="$1"

# Check input params
if [ -z $chain_name ]; then
    echo "ERROR: No chain_name specified. Usage ./create_docker_container.sh kujira kujira-v1"
    exit
fi

docker stop ${chain_name}-loadbalancer
docker rm ${chain_name}-loadbalancer

docker run \
    -p 26657:26657 \
    --network cosmos-net \
    -d \
    --name ${chain_name}-loadbalancer \
    --user root:root \
    haproxy:2.8 \
    bash -c \
    " \
    echo \"$(cat ../chains/${chain_name}/config/haproxy.cfg)\" > /usr/local/etc/haproxy/haproxy.cfg && \
    haproxy -f /usr/local/etc/haproxy/haproxy.cfg -d \
    "