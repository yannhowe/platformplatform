# The Platform platform

## Quick Start
```
git clone https://github.com/yannhowe/platformplatform.git
```

## Offline apt-mirror
```
# apt-mirror and apt-mirror-sync when internet facing
docker-compose -f ./apt-mirror/docker-compose.yml up

# Only need apt-mirror when offline
docker-compose -f ./apt-mirror/docker-compose.yml up apt-mirror
```

