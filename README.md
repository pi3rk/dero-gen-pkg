# Build dero packages

## Install build dependencies

Install fpm https://github.com/jordansissel/fpm

Define fpm bin path in Makefile **FPM_BIN** 

## Generate deb and install them

Simply use :

```
make deb
```

Install tmux as dependency :

```
apt install tmux
```

install dero packages
```
dpkg -i deb/*
``` 

## Usage

db take place in `/var/lib/derod/mainnet`

download dero database :

```
dero-init-db
```

Change your dero node name and description in file `/etc/dero.conf`

Start services :

```
systemctl start derod
systemctl start dero-explorer
systemctl start dero-stats-client
```

to access derod :

```
derod-cli
```

Use `ctrl-b + d` to quit

**/!\ if you exit derod from console, dero will auto restart.
Use systemd service to stop it.**

check your node state there : https://stats.atlantis.dero.live/

# Compatibility

| OS           | Status |
|--------------|--------|
| Ubuntu 18.04 | OK     |
