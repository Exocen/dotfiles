docker run -d \
  --name=transmission \
  -e PUID=1000 \
  -e PGID=1000 \
  -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  -v /docker-data/transmission/:/config \
  -v /DL:/downloads \
  --rm \
  lscr.io/linuxserver/transmission:latest
