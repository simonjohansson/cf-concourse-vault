touch credentials/director_priv.key
chmod 0600 credentials/director_priv.key
bosh int credentials/bosh.yml --path /jumpbox_ssh/private_key > credentials/director_priv.key
ssh jumpbox@192.168.50.6 -i credentials/director_priv.key
