
<p style="font-size:14px" align="right">
<a href="https://t.me/PemulungAirdropID" target="_blank">Join our telegram <img src="https://user-images.githubusercontent.com/72949170/194228482-0f875615-e155-4b12-8716-8111addd6cba.jpg" width="30"/></a>
</p>

<p align="center">
  <img width="60%" height="auto" src="https://user-images.githubusercontent.com/72949170/204932515-60466c99-e0d3-455d-9a15-f164521523d5.png">
</p>

# MISES VALIDATOR (MAINNET)

Official Document
> https://github.com/mises-id/mises-tm

Register Form
> [ Form Validator ](https://docs.google.com/forms/u/0/d/e/1FAIpQLSdTqmA_ZfzIB5rWPI_GVA5X7joPG7ZKI5pU-VreI3_BhY0dtQ/viewform?usp=form_confirm)

Source
> https://www.mises.site/validator

Social Media
> [ Discord ](discord.gg/wQ3qkmBHKt) | [ Twitter ](https://twitter.com/Mises001) | [ Telegram ](t.me/Misesofficial)

|  Komponen |  Persyaratan Minimum |
| ------------ | ------------ |
| OS  | Ubuntu 16.04 ++ |

## 1. Install sat set sat set

```
wget -O mises.sh https://raw.githubusercontent.com/muhamad-ramadhani/mises/main/mises.sh && chmod +x mises.sh && ./mises.sh
```

## 2. Load Variabel
```
source $HOME/.bash_profile
```

```
N/A
```

## 3. Check Node

- Check sync node
```
misestmd status 2>&1 | jq .SyncInfo
```
- Check log node
```
journalctl -fu misestmd -o cat
```
- Check node info
```
misestmd status 2>&1 | jq .NodeInfo
```
- Check validator info
```
misestmd status 2>&1 | jq .ValidatorInfo
```
- Check node id
```
misestmd tendermint show-node-id
```

## 4. Create Wallet
```
misestmd keys add $WALLET
```
Cek Wallet list
```
misestmd keys list
```
Save informasi Wallet
```
MISES_WALLET_ADDRESS=$(misestmd keys show $WALLET -a)
MISES_VALOPER_ADDRESS=$(misestmd keys show $WALLET --bech val -a)
echo 'export MISES_WALLET_ADDRESS='${MISES_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export MISES_VALOPER_ADDRESS='${MISES_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## 5. Create Validator

cek balance
```
misestmd query bank balances $MISES_WALLET_ADDRESS
```
Buat Validator
```
misestmd tx staking create-validator \
  --amount 1000000umis \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(misestmd tendermint show-validator) \
  --moniker $NODENAME \
  --fees 250umis \
  --chain-id $MISES_CHAIN_ID
```

## 6. Delegate
```
misestmd tx staking delegate $MISES_VALOPER_ADDRESS 1000000umis --from=$WALLET --chain-id=MISES_CHAIN_ID --fees=250umis
```

## DONE, UNTUK UPDATE SELANJUTNYA KALIAN BISA PANTAU <a href="https://t.me/PemulungAirdropID" target="_blank">CHANNEL KITA </a>

## Perintah Berguna

recover wallet
```
misestmd keys add $WALLET --recover
```

hapus wallet
```
misestmd keys delete $WALLET
```

edit validator
```
misestmd tx staking edit-validator \
  --moniker="nama-node" \
  --identity="<your_keybase_id>" \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$MISES_CHAIN_ID \
  --fees 250umis \
  --from=$WALLET
```
unjail validator
```
misestmd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$MISES_CHAIN_ID \
  --fees=250umis
```
Voting
```
misestmd tx gov vote 1 yes --from $WALLET --chain-id=$MISES_CHAIN_ID
```
withdraw reward
```
misestmd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$MISES_CHAIN_ID --fees=250umis
```
withdraw reward dengan komisi
```
misestmd tx distribution withdraw-rewards $MISES_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$MISES_CHAIN_ID
```


Stop Node
```
sudo systemctl stop misestmd
```
Restart Node
```
sudo systemctl restart misestmd
```
Hapus node
```
sudo systemctl stop misestmd && \
sudo systemctl disable misestmd && \
rm /etc/systemd/system/misestmd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf mises-tm && \
rm -rf mises.sh && \
rm -rf .misestm && \
rm -rf $(which misestmd)
```

