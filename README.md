# Minecraft Docker Server
A docker image and compose build for running and controlling a Minecraft server from inside a Docker container. 
* Supports any version of Minecraft; you just need a link to the server.jar
    * tested on 1.21, more to come
* Server console access via [RCON](https://minecraft.wiki/w/RCON)
    * uses [Tiiffi/mcrcon](https://github.com/Tiiffi/mcrcon) as a prepackaged RCON client
* All server files stored in a Docker volume
* Graceful shutdown handling (SIGTERM / SIGINT)

## Usage
Requires [Docker](https://docs.docker.com/engine/install/), [Git](https://git-scm.com/install/), and a clone of this repository:
```sh
git clone https://gitea.jovan04.com/evan/minecraft-docker && cd minecraft-docker
```

### Build the Image
```sh
docker build -t minecraft_server .
```

### Run with Docker Compose
`docker-compose.yml` (included in this repository):
```sh
docker compose up -d
```
(or `docker-compose` for older versions of Docker Compose)

### First Startup
On first startup (when the data volume is empty):
* `server.properties` is created from a template
* `eula.txt` is generated and automatically accepted
* A default RCON configuration is written
* `server.jar` is downloaded from a provided link

On subsequent startups, existing files are reused unchanged and environment variables are unused.

### RCON Access
Minecraft implements the Remote Console (RCON) protocol, which allows server administrators to remotely execute commands. See more info [here](https://minecraft.wiki/w/RCON) and [here](https://developer.valvesoftware.com/wiki/Source_RCON_Protocol). RCON access is enabled automatically from inside the container. **Do not expose the RCON service to the internet directly!!!** RCON is not encrypted, so exposing this service can give hackers direct access to your server's administrator console.

Log into the container:
```sh
docker exec -it minecraft_server bash
```
Use the provided wrapper script (located at `/usr/bin/mcrcon`). The script dynamically reads the password from `/minecraft_data/server.properties`. 

Send a single command: 
```sh
mcrcon list
mcrcon stop
```

For an interactive console (`Ctrl-C` or `Ctrl-D` to quit):
```sh
mcrcon
```
Use this the same as typing into the actual server console

### Graceful Shutdown Behavior
When the container receives SIGTERM or SIGINT:
1. A 10-second warning message is broadcast to the server
2. All chunks are saved manually
3. A `stop` command is sent to the Minecraft server
4. The server shuts down normally
5. The container waits up to a configurable timeout before force-exiting, in case large worlds take a long time to save or the server hangs
    * default 120s; configure this by changing the `stop_grace_period` time in `docker-compose.yml`

### Configuration
All Minecraft configuration is done through `server.properties`. Make any necessary changes before **building the image** to the file in this repository, or manually edit the `server.properties` file in the Minecraft server's Docker volume. More info about Docker volumes can be found [here](https://docs.docker.com/engine/storage/volumes). This container should work fine with a relative path in `docker-compose.yml` instead of a named volume. 

