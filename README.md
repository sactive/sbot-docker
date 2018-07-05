# sbot-docker

**Building now**

## Docker build
```bash
./build-image [OPTIONS]
```

**OPTIONS**:

- `-t string`: Set build type ("sbot"|"matternost") (default `sbot`)
- `-v string`: Set image version (default "latest")
- `-b string`: Specify the github branch, if don't specify option `-l`,
the script will automatically pull the code from github and checkout the specify branch(default "master")
- `-p`: Enable push image to docker repository after image builded (default disable)
- `-l`: Build image with local path `sbot` (default disabled)


## Build Mattermost image
```bash
cd ./mattermost
./build-image -t mattermost
```

### Usage
[Mattermost image usage](mattermost/mattermost-docker-doc.md)