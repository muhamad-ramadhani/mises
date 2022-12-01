#!/bin/bash
clear
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo -e "\033[0;35m"
echo "  ______                   _                       _______ _          _                   ";
echo " (_____ \                 | |                     (_______|_)        | |                  ";
echo "  _____) )____ ____  _   _| | _   _ ____   ____    _______ _  ____ __| | ____ ___  ____   ";
echo " |  ____/ ___ |    \| | | | || | | |  _ \ / _  |  |  ___  | |/ ___) _  |/ ___) _ \|  _ \  ";
echo " | |    | ____| | | | |_| | || |_| | | | ( (_| |  | |   | | | |  ( (_| | |  | |_| | |_| | ";
echo " |_|    |_____)_|_|_|____/ \_)____/|_| |_|\___ |  |_|   |_|_|_|   \____|_|   \___/|  __/  ";
echo "                                         (_____|                                  |_|     ";
                                            
echo -e "\e[0m"

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++" 

echo -e '\e[33mTitle :\e[35m' Mises Validator | Mainnet
echo -e '\e[33mAuthor :\e[35m' Rama x PemulungAirdropID
echo -e '\e[33mTelegram Channel :\e[35m' https://t.me/PemulungAirdropID
echo -e '\e[33mTelegram Group :\e[35m' https://t.me/DiskusiPemulungAirdrop
echo -e '\e[33mWebsite :\e[35m' https://pemulungairdrop.space
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"


sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export MISES_CHAIN_ID=mainnet" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$MISES_CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/mises-id/mises-tm/
cd mises-tm/
git checkout 1.0.4
make build
make install


# config
misestmd config chain-id $MISES_CHAIN_ID
misestmd config keyring-backend test

# init
misestmd init $NODENAME --chain-id $MISES_CHAIN_ID

# download genesis and addrbook
curl https://e1.mises.site:443/genesis | jq .result.genesis > ~/.misestm/config/genesis.json

# set peers and seeds
PEERS=40889503320199c676570b417b132755d0414332@rpc.gw.mises.site:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.misestm/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.misestm/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.misestm/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.misestm/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.misestm/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.000025umis\"/" $HOME/.misestm/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.misestm/config/config.toml

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/misestmd.service > /dev/null <<EOF
[Unit]
Description=misestm
After=network-online.target
[Service]
User=$USER
ExecStart=$(which misestmd) start --home $HOME/.misestm
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable misestmd
sudo systemctl restart misestmd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u misestmd -f -o cat\e[0m'
