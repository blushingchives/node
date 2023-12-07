cd /root
kujirad init node --chain-id kaiyo-1 --home /root/.kujira

curl -s -H 'Cache-Control: no-cache' -o /root/.kujira/config/config.toml https://raw.githubusercontent.com/blushingchives/node/main/chains/kujira/config/config.toml
curl -s -H 'Cache-Control: no-cache' -o /root/.kujira/config/app.toml https://raw.githubusercontent.com/blushingchives/node/main/chains/kujira/config/app.toml
curl -s -H 'Cache-Control: no-cache' -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/blushingchives/node/main/rpc/nginx.conf

PEERS=9b7310c0510b26794a204912de0a9c88c19e5b85@65.108.204.225:11856,030f65339defb01b0e3ddaeaa54cbeac00dd0c74@185.182.193.89:26656,c030a6692eb4f39b00b1dbb68e47698230bc2de9@142.132.248.34:11856,70bb20d6078ff90294ebd7c9803de25b73d48955@148.251.77.27:26656,338d79e24ce36a9580ce3e9fce8eeb84e0e6f17b@65.108.130.171:26656,9158c675c4337b5010a3f65857d68c2a3326c2e2@107.181.234.234:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" /root/.kujira/config/config.toml

SNAP_RPC="https://kujira-rpc.polkachu.com:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" /root/.kujira/config/config.toml

/usr/sbin/nginx
kujirad start