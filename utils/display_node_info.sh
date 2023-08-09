
chain_name="$1"
daemon_name="$2"

# Check input params
if [ -z $chain_name ]; then
    echo "ERROR: No chain_name specified. Usage ./display_node_info.sh kujira kujirad"
    exit
fi

if [ -z $daemon_name ]; then
    echo "ERROR: No chain_name specified. Usage ./display_node_info.sh kujira kujirad"
    exit
fi

docker container ls --format "{{.Names}}" | grep "${chain_name}" | while read -r container_name; do
    output=$(docker exec "${container_name}" kujirad status)

    latest_block_height=$(echo "$output" | grep -oE '"latest_block_height":"[0-9]+"')
    catching_up=$(echo "$output" | grep -oE '"catching_up":(true|false)')

    echo
    echo "===================="
    echo "Running 'docker exec ${container_name} ${daemon_name} status' for container: ${container_name}"
    echo "Latest Block Height: ${latest_block_height#*:}"
    echo "Catching Up: ${catching_up#*:}"
    echo "===================="
done