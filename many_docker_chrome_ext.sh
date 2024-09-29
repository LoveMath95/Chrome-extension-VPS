#!/bin/bash

# https://github.com/linuxserver/docker-chromium

#tao them nhieu puid de chay nhieu docker
PUID_const=992
NEW_USER="abc2"

groupadd -g $PUID_const $NEW_USER
useradd -u $PUID_const -g $PUID_const $NEW_USER


#tao thong tin dang nhap vao chromium
CUSTOM_USER=$(openssl rand -hex 4)  
PASSWORD=$(openssl rand -hex 12)   
TIMEZONE="Asia/Jakarta" 

echo "Generated username: $CUSTOM_USER"
echo "Generated password: $PASSWORD"

#tao thu muc rieng cho moi docker chrome
NEW_FOLDER="chromium2"
CONTAINER_NAME_const="chromium2"

echo "Setting up Chromium with Docker Compose..."
mkdir -p $HOME/$NEW_FOLDER && cd $HOME/$NEW_FOLDER

# dont forget to change ports

cat <<EOF > docker-compose.yaml
---
services:
  chromium:
    image: lscr.io/linuxserver/chromium:latest
    container_name: $CONTAINER_NAME_const
    security_opt:
      - seccomp:unconfined
    environment:
      - CUSTOM_USER=$CUSTOM_USER
      - PASSWORD=$PASSWORD
      - PUID=$PUID_const
      - PGID=$PUID_const
      - TZ=$TIMEZONE
      - LANG=en_US.UTF-8
      - CHROME_CLI=https://google.com/
    volumes:
      - /root/$CONTAINER_NAME_const/config:/config
    ports:
      - 3014:3000
      - 3015:3001
    shm_size: "1gb"
    restart: unless-stopped
EOF

if [ ! -f "docker-compose.yaml" ]; then
    echo "Failed to create docker-compose.yaml. Exiting..."
    exit 1
fi


# chuyen quyen owner cua thu muc trong volume cua docker cho user moi tao (neu khong se bao loi)
sudo chown -R $NEW_USER:$NEW_USER /root/$NEW_FOLDER

echo "Running Chromium container..."
cd $HOME/$NEW_FOLDER
docker-compose up -d

IPVPS=$(curl -s ifconfig.me)

echo "Access Chromium in your browser at: http://$IPVPS:3010/ or https://$IPVPS:3011/"
echo "Username: $CUSTOM_USER"
echo "Password: $PASSWORD"
echo "Please save your data, or you will lose access!"

docker system prune -f
echo "Docker system pruned. Setup complete!"
