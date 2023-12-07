cd /root
kujirad init node --chain-id kaiyo-1 --home /root/.kujira

curl -s -H 'Cache-Control: no-cache' -o /root/.kujira/config/config.toml https://raw.githubusercontent.com/blushingchives/node/main/chains/kujira/config/config.toml
curl -s -H 'Cache-Control: no-cache' -o /root/.kujira/config/app.toml https://raw.githubusercontent.com/blushingchives/node/main/chains/kujira/config/app.toml
curl -s -H 'Cache-Control: no-cache' -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/blushingchives/node/main/rpc/nginx.conf

SEEDS=ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:11856,63158c2af0d639d8105a8e6ca2c53dc243dd156f@seed.kujira.mintserve.org:31897,20e1000e88125698264454a884812746c2eb4807@seeds.lavenderfive.com:11856,322abfd7c0bcdf8a3d98ccb46ae2572bae0e8301@seed-kujira.starsquid.io:15602,824fa337b806bd48ce9505d74ba3e5adea80da93@seeds.goldenratiostaking.net:1628,c28827cb96c14c905b127b92065a3fb4cd77d7f6@seeds.whispernode.com:11856
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" /root/.kujira/config/config.toml

# PEERS=9b7310c0510b26794a204912de0a9c88c19e5b85@65.108.204.225:11856,030f65339defb01b0e3ddaeaa54cbeac00dd0c74@185.182.193.89:26656,c030a6692eb4f39b00b1dbb68e47698230bc2de9@142.132.248.34:11856,70bb20d6078ff90294ebd7c9803de25b73d48955@148.251.77.27:26656,338d79e24ce36a9580ce3e9fce8eeb84e0e6f17b@65.108.130.171:26656,9158c675c4337b5010a3f65857d68c2a3326c2e2@107.181.234.234:26656
# sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" /root/.kujira/config/config.toml

# SNAP_RPC="https://kujira-rpc.polkachu.com:443"
# LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
# BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
# TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
# sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
# s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
# s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
# s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" /root/.kujira/config/config.toml

SNAPSHOTBLOCK=15897065
wget --no-verbose -O snapshot.tar.lz4 https://snapshots.polkachu.com/snapshots/kujira/kujira_${SNAPSHOTBLOCK}.tar.lz4 --inet4-only
kujirad tendermint unsafe-reset-all --home /root/.kujira --keep-addr-book
lz4 -c -d snapshot.tar.lz4  | tar -x -C /root/.kujira
rm -v snapshot.tar.lz4

/usr/sbin/nginx
kujirad start