# usage: ./docker_service_create.sh chain_name
# eg., ./docker_service_create.sh kujira

chain_name="$1"
container_name="$2"

# Check input params
if [ -z $chain_name ]; then
    echo "ERROR: No chain_name specified. Usage ./create_docker_container.sh kujira kujira-v1"
    exit
fi

if [ -z $container_name ]; then
    echo "ERROR: No docker_volume specified. Usage ./create_docker_container.sh kujira kujira-v1"
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

if [[ -z $(docker image ls | grep "${daemon_name}") ]]; then
    echo "ERROR: Build chain daemon first."
    exit
fi

docker stop ${container_name} && \
docker rm ${container_name} || true && \
docker run \
    -it \
    --volume ${container_name}-volume:${node_home} \
    --name ${container_name} \
    kujirad \
    bash -c \
    " \
    echo \"$(cat ../chains/${chain_name}/config/app.toml | sed 's/\"/<>!spacing<>/g')\" > /root/.kujira/config/app.toml && \
    sed -i 's/<>!spacing<>/\"/g' /root/.kujira/config/app.toml && \
    echo \"$(cat ../chains/${chain_name}/config/config.toml | sed 's/\"/<>!spacing<>/g')\" > /root/.kujira/config/config.toml && \
    sed -i 's/<>!spacing<>/\"/g' /root/.kujira/config/config.toml && \
    $(cat run.sh) \
    "
        # ls /root/.kujira/config \
    # $(cat run.sh) \

    #     """ \
    # echo \"$(cat ../chains/${chain_name}/config/config.toml | sed 's/\"/<>!spacing<>/g')\" > /root/.kujira/config/config.toml | sed 's/| sed 's/\"/<>!spacing<>/g'/\"/g' && \
    # echo \"$(cat ../chains/${chain_name}/config/app.toml | sed 's/\"/<>!spacing<>/g')\" > /root/.kujira/config/app.toml | sed 's/| sed 's/\"/<>!spacing<>/g'/\"/g' &&  \
    # cat /root/.kujira/config/app.toml \
    # """