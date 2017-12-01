touch vbox/director_priv.key
chmod 0600 vbox/director_priv.key
bosh int vbox/creds.yml --path /jumpbox_ssh/private_key > box/director_priv.key
ssh jumpbox@192.168.50.6 -i vbox/director_priv.key
