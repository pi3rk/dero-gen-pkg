# Create dero packages

## Build Dependency

Install fpm https://github.com/jordansissel/fpm

Define fpm bin path in Makefile 

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

Change your dero node name and description in file `/etc/default/dero`

Start services :

```
systemctl start derod dero-stats-client dero-explorer
systemctl start dero-stats-client
systemctl start dero-explorer
```

to access derod :

```
derod-cli
```

Use `ctrl-b + d` to quit

/!\ if you exit derod from console, dero will auto restart.
Use systemd service to stop it.

check your node state there : https://stats.atlantis.dero.live/

# Compatibility

| OS           | Status |
|--------------|--------|
| Ubuntu 18.04 | OK     |
