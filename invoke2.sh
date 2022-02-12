
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
