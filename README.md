# mdns-repeater

mdns-repeater is a Multicast DNS repeater for Linux. Multicast DNS uses the
224.0.0.251 address, which is "administratively scoped" and does not
leave the subnet.

This program re-broadcast mDNS packets from one interface to other interfaces.
The original intention from Darell Tan was to run this on his Linksys WRT54G
which runs dd-wrt. Since his wireless network was on a different subnet from
his wired network, zeroconf devices didn't work properly across subnets. My
intention is the ability to bridge my physical network and my Docker network(s),
hence the Docker image.

Since the mDNS protocol sends the AA records in the packet itself, the
repeater does not need to forge the source address. Instead, the source
address is of the interface that repeats the packet.

<details>
<summary>Differences from Darell Tan's version</summary>

- Replaced any Mercurial reference with Git
- Added separate foreground and foreground debug mode
- Added Docker support
- Added versioning based on Git hash or Git tag
- Added [EditorConfig](https://editorconfig.org/)

</details>


## Usage

mdns-repeater only requires the interface names and it will do the rest. For
example when bridging a default bridge network with a default wireless network
the command looks like this:

```bash
mdns-repeater br0 wlan1
```

> [!NOTE]
> Usage is shown with `mdns-repeater -h`

### Container

To bridge an existing physical network to a Docker (Swarm) Overlay network it
is necessary that the container has access to both networks. This can be
achieved with [Host networking](https://docs.docker.com/engine/network/drivers/host/),
a [macvlan](https://docs.docker.com/engine/network/drivers/macvlan/) network
or [ipvlan](https://docs.docker.com/engine/network/drivers/ipvlan/) network.
Although Host networking should be supported, this is not recommended because
of possible port conflicts.

#### Docker

This is a very basic example bridging `br0` with `swarm-overlay`. Actual
network names and options may differ.

```bash
docker run -d \
           --name mdns-repeater \
           --network br0 \
           --network swarm-overlay \
           alex3305/mdns-repeater:latest -f eth0 eth1
```

A [Docker Compose](./docker-compose.yml) example with [.env][./.env.example] is
also available in the root of this repository.

> [!TIP]
> The container accepts the same arguments as running the application on
> bare metal.

### Flags

#### Execution Mode

mdns-repeater can be ran in three modes, detached (default), foreground or
debug mode. When running in detached mode, the application is daemonized to
the background and will not show any logging.

It is also possible to run mdns-repeater in foreground mode by providing the
`-f` flag. This will keep mdns-repeater in the foreground and is used within
the container. It is also possible to run debug mode with `-x`. This will also
keep mdns-repeater in the foreground, but will also echo received messages.

#### Blacklist and whitelist subnets

It is possible to black- or whitelist subnets by providing the `-b` and `-w`
flags. Subnets are provided in the CIDR notation. These flags are exclusive to
each other, but it is possible to provide multiple subnets. The maximum number
of subnets that may be provided is 16.

<details>
<summary>Show advanced options</summary>

#### Custom PID file

A custom pid file path may be provided if the default isn't sufficient with
`-p`. This should be an absolute path.

#### Run as different user

With the `-u` flag it is possible to run mdns-repeater as another user.

</details>


## Development

For development the following dependencies are required:

- git
- gcc
- musl-dev
- make

For building the container either Docker or an OCI alternative, such as
[podman](https://podman.io/) is required.

### Build

Building is done with `make`.

### Container build

The container can be build with [`docker buildx build`](https://docs.docker.com/reference/cli/docker/buildx/) or with `make`:

```bash
docker buildx build . -t mdns-repeater
# OR
make docker
```

The Dockerfile consists of multiple stages. In the first stage the development
dependencies are installed and the application is built. In the second stage,
the build result is copied into a fresh Alpine image to minimize size.

### Forgejo Actions

Forgejo Actions is used to build the software on my personal Git server. These
workflows are also included.

## Versioning

The version is automatically set through Git. If the current revision points
to a tag, the tag name will be used as the application version. Otherwise a
shortened revision hash is used.

## License

Copyright (C) 2011 Darell Tan
Copyright (C) 2025 Alex van den Hoogen

This program is free software distributed under the
[GNU GPL v2 license](./LICENSE).

Docker and the Docker logo are trademarks or registered trademarks of Docker,
Inc. in the United States and/or other countries.
