cd /root
kujirad init node --chain-id kaiyo-1 --home /root/.kujira

curl -s -o /root/.kujira/config/config.toml https://raw.githubusercontent.com/blushingchives/node/main/chains/kujira/config/config.toml
curl -s -o /root/.kujira/config/app.toml https://raw.githubusercontent.com/blushingchives/node/main/chains/kujira/config/app.toml
curl -s -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/blushingchives/node/main/chains/kujira/config/nginx.conf

SEEDS=ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:11856,63158c2af0d639d8105a8e6ca2c53dc243dd156f@seed.kujira.mintserve.org:31897
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" /root/.kujira/config/config.toml

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