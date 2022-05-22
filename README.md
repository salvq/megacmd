# Mega.nz megacmd for QNAP servers

This is a container for the megacmd tool. Designed with convenience functions, intended to use for backing up data a regular intervals.

Inspired by https://github.com/Cossey/docker/tree/master/megacmd

## Supported Platforms

* linux/amd64

## Prerequisites

Create folder `megacmd` and empty file `megacmd.cfg` within that folder, for example `/share/Container/megacmd/megacmd.cfg`

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

To run upload every day at 1:30 AM, you can register application via QNAP UI (Create Application in ContainerStation using docker-compose.yaml)

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

1.) Install qpkg megacmd, use app center in QTS or download and install https://download.qnap.com/QPKG/MEGAcmd_1.4.0_x86_64.zip

2.) ssh to qnap and run commands (adjust export path if needed)

3.) Copy/paste sessionid to docker-compose file

4.) Logout from mega-cmd and keep session active

```
[/share/CE_CACHEDEV1_DATA] # export PATH=/share/CE_CACHEDEV1_DATA/.qpkg/MEGAcmd:$PATH
[/share/CE_CACHEDEV1_DATA] # mega-cmd
MEGA CMD> login username@username.com password
username@username.com:/$ session
Your (secret) session is: YOURSESSIONID
username@username.com:/$ logout --keep-session
exit
```
