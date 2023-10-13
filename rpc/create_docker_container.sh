# usage: ./docker_service_create.sh chain_name
# eg., ./docker_service_create.sh kujira

daemon_version="$1"
chain_name="$2"
container_name="$3"

# Check input params
if [ -z $daemon_version ]; then
    echo "ERROR: No daemon_version specified. Usage ./create_docker_container.sh kujira-v0.8.7 kujira kujira-1"
    exit
fi

if [ -z $chain_name ]; then
    echo "ERROR: No chain_name specified. Usage ./create_docker_container.sh kujira-v0.8.7 kujira kujira-1"
    exit
fi

if [ -z $container_name ]; then
    echo "ERROR: No docker_volume specified. Usage ./create_docker_container.sh kujira-v0.8.7 kujira kujira-1"
    exit
fi

# Check config files
if ! test -f "../chains/${chain_name}/${chain_name}.conf"; then
    echo "ERROR: Chain config does not exists. Check ./chains/${chain_name}/${chain_name}.conf"
    exit
fi

if ! test -f "../chains/${chain_name}/config/config.toml"; then
    echo "ERROR: Chain config does not exists. Check ./chains/${chain_name}/config/config.toml"
    exit
fi

if ! test -f "../chains/${chain_name}/config/app.toml"; then
    echo "ERROR: Chain config does not exists. Check ./chains/${chain_name}/config/app.toml"
    exit
fi

# Load kujira.conf params
eval "$(cat ../chains/${chain_name}/${chain_name}.conf |sed 's/ = /=/g')"
echo "git_repo: ${git_repo}"
echo "version: ${version}"
echo "daemon_name: ${daemon_name}"
echo "node_home: ${node_home}"

if [[ -z $(docker image ls | grep "${daemon_version}") ]]; then
    echo "ERROR: Build chain daemon first."
    exit
fi

docker stop ${container_name}
docker rm ${container_name}
docker volume rm ${container_name}-volume

docker run \
    --network cosmos-net \
    -d \
    --volume ${container_name}-volume:${node_home} \
    --name ${container_name} \
    --user root:root \
    ${daemon_version} \
    bash -c \
    " \
    $(cat run.sh) \
    "
# echo \"$(cat ../chains/${chain_name}/config/app.toml | sed 's/\"/<>!spacing<>/g')\" > /root/.kujira/config/app.toml && \
#     sed -i 's/<>!spacing<>/\"/g' /root/.kujira/config/app.toml && \
#     echo \"$(cat ../chains/${chain_name}/config/config.toml | sed 's/\"/<>!spacing<>/g')\" > /root/.kujira/config/config.toml && \
#     sed -i 's/<>!spacing<>/\"/g' /root/.kujira/config/config.toml && \