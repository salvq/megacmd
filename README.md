# Mega.nz megacmd for QNAP servers

This is a container for the megacmd tool. Designed with convenience functions, intended to use for backing up data in regular intervals.

Logic used here is to run several containers in paralel i.e., each container with different folder. This way, you can speed up not the data upload of course but decrease time to compare local files list vs. cloud file list.

Note: you may also use only 1 container with all the backup folder(s) within a container but his will take much longer as all the folders will be done in sequence rather than in paralel.

Inspired by https://github.com/Cossey/docker/tree/master/megacmd

## Supported Platforms

* linux/amd64

## Prerequisites

Create folder `megacmd` and an empty file `megacmd.cfg` within that folder, for example `/share/Container/megacmd/megacmd.cfg`

File `megacmd.cfg` stores configuration information such as download and/or upload speed. 

Once you limit your upload speed to 640000 B/s in running container via `mega-speedlimit -u 640000`, it will be written to cfg file and used by any other container which is linked to this file.

## Container Configuration

| Name     | Description                                                                                                 |
| -------- | ----------------------------------------------------------------------------------------------------------- |
| USERNAME | The mega account username. *Required if SESSION not supplied.*                                              |
| PASSWORD | The mega account password. *Required if SESSION not supplied.*                                              |
| SESSION  | The mega login session. *Required if USERNAME and PASSWORD not supplied.*                                   |
| MEGACMD  | The command to pass to the megacmd program. You don't need to prefix the `mega-` to the command. *Required.* |
| INTERVAL | The time in minutes to repeat the command. Leave blank or set to 0 exit immediately.                        |
| BEGIN    | The time in HHMM UTC to first run the command. If not set will run immediately.                             |

If the `BEGIN` command is set, then the `INTERVAL` will be set to 1440 (one day) automatically. If you want to override this then set `INTERVAL` to the delay you want (you can also set it to `0` to exit immediately).

For a list of program commands and user guide, visit https://github.com/meganz/MEGAcmd/blob/master/UserGuide.md

## Usage

It is recommended to use sessionID instead of username and passowrd, see below how to create sessionID

To run upload every week at 1:30 AM, you can register an application via QNAP UI (Create Application in ContainerStation using docker-compose.yaml) or just run command in shell in folder with all the files `[~] # docker-compose up -d`

```
version: '3'

services:
  megacmd-camera:
    image: salvq/megacmd:1.5.0
    container_name: megacmd-camera
    restart: unless-stopped
    network_mode: host
    environment:
      - SESSION=YOURSESSIONID
      - BEGIN=0130
      - INTERVAL=10080
      - MEGACMD=put -c /backup/* /
    volumes:
      - /share/Download/Rasto/Camera:/backup/Camera/:ro
      - /share/Container/megacmd/megacmd.cfg:/root/.megaCmd/megacmd.cfg
      - /etc/localtime:/etc/localtime:ro
    logging:
      driver: "syslog"
      options:
        syslog-address: "tcp://192.168.1.106:514"
        tag: "{{.Name}}/{{.ImageName}}"
  megacmd-documents:
    image: salvq/megacmd:1.5.0
    container_name: megacmd-documents
    restart: unless-stopped
    network_mode: host
    environment:
      - SESSION=YOURSESSIONID
      - BEGIN=0130
      - INTERVAL=10080
      - MEGACMD=put -c /backup/* /
    volumes:
      - /share/Download/Rasto/Documents:/backup/Documents/:ro
      - /share/Container/megacmd/megacmd.cfg:/root/.megaCmd/megacmd.cfg
      - /etc/localtime:/etc/localtime:ro
    logging:
      driver: "syslog"
      options:
        syslog-address: "tcp://192.168.1.106:514"
        tag: "{{.Name}}/{{.ImageName}}"
        
```


## Session IDs

To generate a session id, follow below steps:

1.) Install qpkg megacmd

- Use app center in QTS or install manually by downloading from https://download.qnap.com/QPKG/MEGAcmd_1.4.0_x86_64.zip

2.) ssh to qnap and set PATH (adjust path if needed / when installed in different folder)
```
[/share/CE_CACHEDEV1_DATA] # export PATH=/share/CE_CACHEDEV1_DATA/.qpkg/MEGAcmd:$PATH
```
3.) Initiate mega-cmd
```
[/share/CE_CACHEDEV1_DATA] # mega-cmd
```
4.) Login to mega cloud
```
MEGA CMD> login username@username.com password
```
5.) Copy/paste sessionid for docker-compose file
```
username@username.com:/$ session
Your (secret) session is: YOURSESSIONID
```
4.) Logout from mega-cmd and keep session active
```
username@username.com:/$ logout --keep-session
```
