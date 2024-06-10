![Docker Image Version (latest semver)](https://img.shields.io/docker/v/akito13/nim?style=plastic)

![Docker Stars](https://img.shields.io/docker/stars/akito13/nim?style=plastic)
![Docker Pulls](https://img.shields.io/docker/pulls/akito13/nim?style=plastic)

![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/akito13/nim?style=plastic)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/akito13/nim?style=plastic)

[![Upstream](https://img.shields.io/badge/upstream-project-yellow?style=plastic)](https://github.com/nim-lang/Nim)

![GitHub](https://img.shields.io/github/license/theAkito/docker-nim?style=plastic)
![Liberapay patrons](https://img.shields.io/liberapay/patrons/Akito?style=plastic)

## What
Nim compiler in Docker images, but with support for multiple platforms.

## Why
The current official [Nimage](https://github.com/moigagoo/nimage) only supports [`linux/amd64` builds](https://hub.docker.com/r/nimlang/nim/tags).
This one supports at least the following platforms, based on what the [Ubuntu base images](https://hub.docker.com/_/ubuntu/tags) support.

```
linux/ppc64le
linux/arm/v7
linux/arm64/v8
linux/amd64
```

The [Alpine based images](https://hub.docker.com/_/alpine/tags) support the following architectures.

```
linux/ppc64le
linux/arm/v7
linux/arm64/v8
linux/amd64
```

## How
Semver tags are referring to the Nim version contained in that particular image.

## Get
#### Latest build
```bash
docker pull akito13/nim
```
#### Fixed version
```bash
docker pull akito13/nim:2.0.4
```
Tags follow semver, without the `v`.
Git tags equal Docker tags, so no need to check tags explicitly on Docker Hub.

## Build
#### Build yourself
```bash
bash docker-build.sh
```

## Run

#### Create Test File
```bash
echo 'import std/json; echo """{"hello":"test"}""".parseJson.pretty' > t.nim
```

#### Rootless
If you simply need to compile something, always use the rootless image.

```bash
docker run -itv "$PWD:/cwd" --rm akito13/nim:2.0.4-rootless bash -c "nim c -r /cwd/t.nim && rm /cwd/t"
```

#### Root
If you compile or install something, which depends on libraries installed through `apt` or otherwise need root access, you can use the `root` based image.

```bash
docker run -it --rm akito13/nim:2.0.4 bash -c "apt update && apt install -y libncurses-dev && nimble install -y moe"
```

You may also run the rootless image as `root`, if you don't want to download an additional image & instead re-use the already existing rootless one.

```bash
docker run -it --rm --user root akito13/nim:2.0.4-rootless bash -c "apt update && apt install -y libncurses-dev && nimble install -y moe"
```

### Alpine
You may also use the [Alpine](https://www.alpinelinux.org/) based images.

```sh
docker run -it --rm akito13/nim:2.0.4-alpine sh -c "apk --no-cache add ncurses-dev pcre && nimble install -y moe"
```


## License
Copyright © 2022-2024  Akito <the@akito.ooo>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.