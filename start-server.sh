#!/bin/bash

# initialize required files for an empty volume
# server.jar
if ! test -f /minecraft_data/server.jar; then
    if [ -z "$SERVER_JAR_DOWNLOAD_URL" ]; then
        echo "ERROR: SERVER_JAR_DOWNLOAD_URL not set for initial volume creation"
        exit 1
    fi
    wget -O /minecraft_data/server.jar "${SERVER_JAR_DOWNLOAD_URL}"
fi

# server.properties
if ! test -f /minecraft_data/server.properties; then
    if [ -z "$MCRCON_PASS" ]; then
        echo "ERROR: MCRCON_PASS not set for initial volume creation"
        exit 1
    fi
    cat /defaults/server.properties | sed "s/<password_will_auto_populate>/${MCRCON_PASS}/" | tee /minecraft_data/server.properties
fi

# eula.txt
if ! test -f /minecraft_data/eula.txt; then
    cp /defaults/eula.txt /minecraft_data/eula.txt
fi

export MCRCON_PASS=$(grep "^rcon.password=" /minecraft_data/server.properties | cut -d '=' -f 2- | head -n 1)

# shutdown process
function shutdown {
    echo "stopping Minecraft server..."
    /usr/bin/mc-rcon/mcrcon -p ${MCRCON_PASS} -w 5 "say Server is restarting!" save-all stop
    wait $SERVER_PID
}

trap shutdown SIGTERM SIGINT

java -jar /minecraft_data/server.jar --nogui & 
SERVER_PID=$!

wait $SERVER_PID

