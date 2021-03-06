#!/bin/bash

########################################################################################################
#Author: Kennashka DeSilva
#mail@kennashka.com
#Feb 11, 2022
########################################################################################################


# Install ipfs

curl -O https://dist.ipfs.io/go-ipfs/v0.11.0/go-ipfs_v0.11.0_darwin-amd64.tar.gz

tar -xvzf go-ipfs_v0.11.0_darwin-amd64.tar.gz

########################################################################################################

# > x go-ipfs/install.sh
# > x go-ipfs/ipfs
# > x go-ipfs/LICENSE
# > x go-ipfs/LICENSE-APACHE
# > x go-ipfs/LICENSE-MIT
# > x go-ipfs/README.md


cd go-ipfs
bash install.sh

# > Moved ./ipfs to /usr/local/bin

ipfs --version

# > ipfs version 0.11.0

mkdir kennashka


touch index.html style.css
FILE="./index.html"

/bin/cat << 'EOF' > $FILE

Hello World

EOF


mv index.html style.css kennashka

echo "Your First IPFS SITE IS Successful"

ipfs init

ipfs daemon &

ipfs add -r kennashka/
