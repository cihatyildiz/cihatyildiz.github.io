---
title: A Cheatsheet for Docker
author: Cihat Yildiz
date: 2020-10-01 20:55:00 +0800
categories: [docker, cheatsheet]
tags: [docker]
pin: false
---

if you are using Docker in your local or remote ennvironment, sometimes you might have trouble to manage Docker images and containers. I want to share a small cheatsheet that I used. I think this is very short and usefull cheatsheet. 
<!--more-->
# Export/Import 

Export docker image to tar file: 
```
docker export <container-name> > latest.tar
```
```
docker export --output="latest.tar" <container-name>
```

Import docker image via stdin:
```
cat image.tgz | docker import - imagelocal:new
```

Import with a commit message
```
cat image.tgz | docker import --message "New image imported from tarball" - imagelocal:new
```

Import to docker from a local archive:
```
docker import /path/to/image.tgz
```

# Image Snapshots!

Basiscally commit commad shohuld be used for snnapshot operations. That snapshot is an image, which you can put on a (private) repository to be able to pull it on another host.
```
docker commit
```

Downnload image from private registery. 
```
docker login myrepo.com
docker pull myrepo.com/myimage
docker pull myrepo.com/myimage:mytag
```

If you dont specify a private repo, docker will try to download thhe image from docker-hub
```
docker pull debian
```

# Other Docker Commands

Manage the Docker serivice:
```
service docker start/stop/status/restart
```

list running docker containers:
```
docker ps
```

Open a shell in a container: 
```
docker exec -it <container-name> /bin/bash
```

run a command innside docker:
```
docker exec <container-name> <command>
```

list docker images:
```
docker image ls
```
```
docker images
```

list docker cotainers:
```
docker container ls
```

remove all docker images:
```
docker rmi $(docker images)
```

run docker image:
```
docker run <image-name>
```

stop docker image:
```
docker stop <containenr-name>
```

stop running container through SIGKILL:
```
docker stop <image-name>
```

list conntainer networks:
```
docker network ls
```

pull docker image from docker-hub repository:
```
docker pull kalilinux/kali
```

Remove unused data:
```
docker system prune
```

# Reference Cheatsheets
* [https://www.docker.com/sites/default/files/d8/2019-09/docker-cheat-sheet.pdf](https://www.docker.com/sites/default/files/d8/2019-09/docker-cheat-sheet.pdf)
* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
* [docker-compose reference](https://morioh.com/p/b1b47d94f1de)
* [Snapshoht a docker container](https://winsmarts.com/snapshot-a-docker-container-20df59bbd473)

