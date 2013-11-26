#!/usr/bin/bash

echo "#!/usr/bin/bash" > temp.sh
sed -n '$2,$3p' $1 >> temp.sh
chmod +x temp.sh
./temp.sh
rm temp.sh

