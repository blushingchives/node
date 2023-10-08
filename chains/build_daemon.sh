# usage: ./build_daemon.sh chain_name
# eg., ./build_daemon.sh kujira

chain_name="$1"
version="$2"

# Check input params
if [ -z $chain_name ]; then
    echo "ERROR: No chain_name specified. Usage ./build_daemon.sh chain_name version"
    exit
fi

if [ -z $version ]; then
    echo "ERROR: No chain_name specified. Usage ./build_daemon.sh chain_name version"
    exit
fi

docker build -t ${chain_name}-${version} ./${chain_name}/daemon/${version}