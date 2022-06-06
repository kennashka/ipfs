
#!/bin/bash

########################################################################################################
#Author: Kennashka DeSilva
#mail@kennashka.com
#Feb 11, 2022
########################################################################################################


# Install ipfs
wget https://dist.ipfs.io/go-ipfs/v0.11.0/go-ipfs_v0.11.0_linux-amd64.tar.gz

tar -xvzf go-ipfs_v0.11.0_linux-amd64.tar.gz


########################################################################################################

# > x go-ipfs/install.sh
# > x go-ipfs/ipfs
# > x go-ipfs/LICENSE
# > x go-ipfs/LICENSE-APACHE
# > x go-ipfs/LICENSE-MIT
# > x go-ipfs/README.md


cd go-ipfs
sudo bash install.sh

# > Moved ./ipfs to /usr/local/bin

ipfs --version

# > ipfs version 0.11.0

touch index.html style.css
FILE="./index.html"

/bin/cat << 'EOF' > $FILE

<!DOCTYPE html>
<link rel="stylesheet" type="text/css" href="styles.css">
<html>
    <body>
        <h1>MY IPFS SITE</h1>
        <p>Hello World</p>
    </body>
</html>
EOF

echo "Done"

FILE="./style.css"

/bin/cat << 'EOF' > $FILE
body {
    background-color: #ccc;
}
EOF

echo "Done"

mkdir kennashka/

mv index.html style.css kennashka/

ipfs init

ipfs daemon &

ipfs add -r kennashka/


# Installing Stacks API

# create some files/dirs for persistent data,
# we'll first create a base directory structure and set some permissions:

sudo mkdir -p /stacks-node/{persistent-data/stacks-blockchain,bns,config,binaries}

sudo chown -R $(whoami) /stacks-node 

cd /stacks-node


PG_VERSION=12 \
  && NODE_VERSION=16 \
  && sudo apt-get update \
  && sudo apt-get install -y \
    gnupg2 \
    git \
    lsb-release \
    curl \
    jq \
    openjdk-11-jre-headless \
    build-essential \
    zip \
  && curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgsql.list \
  && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo bash - \
  && sudo apt-get update \
  && sudo apt-get install -y \
    postgresql-${PG_VERSION} \
    postgresql-client-${PG_VERSION} \
    nodejs


curl -L https://storage.googleapis.com/blockstack-v1-migration-data/export-data.tar.gz -o /stacks-node/bns/export-data.tar.gz

tar -xzvf ./bns/export-data.tar.gz -C /stacks-node/bns/


# To Verify, run a script like the following to check the sha256sum:

for file in `ls /stacks-node/bns/* | grep -v sha256 | grep -v .tar.gz`; do
    if [ $(sha256sum $file | awk {'print $1'}) == $(cat ${file}.sha256 ) ]; then
        echo "sha256 Matched $file"
    else
        echo "sha256 Mismatch $file"
    fi
done


cat <<EOF> /tmp/file.sql
create role stacks login password 'password';
create database stacks_db;
grant all on database stacks_db to stacks;
EOF

sudo su - postgres -c "psql -f /tmp/file.sql" && rm -f /tmp/file.sql

echo "local   all             stacks                                  md5" | sudo tee -a /etc/postgresql/12/main/pg_hba.conf

sudo systemctl restart postgresql

git clone https://github.com/hirosystems/stacks-blockchain-api /stacks-node/stacks-blockchain-api && cd /stacks-node/stacks-blockchain-api \
  && echo "GIT_TAG=$(git tag --points-at HEAD)" >> .env \
  && npm config set unsafe-perm true \
  && npm install \
  && npm run build \
  && npm prune --production

cat <<EOF> /stacks-node/stacks-blockchain-api/.env
NODE_ENV=production
GIT_TAG=master
PG_HOST=localhost
PG_PORT=5432
PG_USER=stacks
PG_PASSWORD=password
PG_DATABASE=stacks_db
STACKS_CHAIN_ID=0x00000001
V2_POX_MIN_AMOUNT_USTX=90000000260
STACKS_CORE_EVENT_PORT=3700
STACKS_CORE_EVENT_HOST=0.0.0.0
STACKS_BLOCKCHAIN_API_PORT=3999
STACKS_BLOCKCHAIN_API_HOST=0.0.0.0
STACKS_CORE_RPC_HOST=localhost
STACKS_CORE_RPC_PORT=20443
#BNS_IMPORT_DIR=/stacks-node/bns
EOF

cd /stacks-node/stacks-blockchain-api && nohup node ./lib/index.js &

ps -ef | grep "lib/index.js" | grep -v grep

# sudo kill $(ps -ef | grep "lib/index.js" | grep -v grep | awk {'print $2'})



