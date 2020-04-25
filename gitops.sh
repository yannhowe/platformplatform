#!/bin/sh
cd "$(dirname "$0")"

if [ ! -d .git ]; then
    echo "Error: Current directory (`pwd`) is not a git repository!"
    exit 2
fi

echo "`date --iso-8601` gitops platformplatform"

git fetch
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ $LOCAL != $REMOTE ]; then
    git pull origin $(git rev-parse --abbrev-ref HEAD)
    ./platformplatform.sh pull
    ./platformplatform.sh restart
fi
