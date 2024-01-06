chain_name="$1"
container_name="$2"
new_chain_version="$3"
new_chain_height="$4"
home_path="$5"

# Check input params
if [ -z $chain_name ]; then
    echo "ERROR: No chain_name specified. Usage ./schedule_chain_upgrade.sh kujira kujira-1 kujira-v0.8.7 12345 ~/user/Coding stuff/node"
    exit
fi

if [ -z $container_name ]; then
    echo "ERROR: No container_name specified. Usage ./schedule_chain_upgrade.sh kujira kujira-1 kujira-v0.8.7 12345 ~/user/Coding stuff/node"
    exit
fi

if [ -z $new_chain_version ]; then
    echo "ERROR: No new_chain_version specified. Usage ./schedule_chain_upgrade.sh kujira kujira-1 kujira-v0.8.7 12345 ~/user/Coding stuff/node"
    exit
fi

if [ -z $new_chain_height ]; then
    echo "ERROR: No new_chain_height specified. Usage ./schedule_chain_upgrade.sh kujira kujira-1 kujira-v0.8.7 12345 ~/user/Coding stuff/node"
    exit
fi

if [ -z $home_path ]; then
    echo "ERROR: No home_path specified. Usage ./schedule_chain_upgrade.sh kujira kujira-1 kujira-v0.8.7 12345 ~/user/Coding stuff/node"
    exit
fi

if ! docker images --format "{{.Repository}}" | grep -q "^${new_chain_version}$"; then
    echo "Image '${new_chain_version}' does not exist. Please build daemon first."
    exit 1
fi

# Create the cron job script
mkdir -p $HOME/cron_scripts
cat > "$HOME/cron_scripts/$container_name-$new_chain_version.sh" << EOL
#!/bin/bash

STATUS=\$(docker exec $container_name kujirad status)
HEIGHT=\$(echo \$STATUS | jq -r '.SyncInfo.latest_block_height')
echo "$container_name | \$STATUS"

if [[ \$HEIGHT == "$new_chain_height" ]]; then
    $home_path/rpc/create_docker_container.sh $new_chain_version $chain_name $container_name

    rm -f "$HOME/cron_scripts/$container_name-$new_chain_version.sh"
fi
EOL

# Make the cron script executable
chmod +x "$HOME/cron_scripts/$container_name-$new_chain_version.sh"
