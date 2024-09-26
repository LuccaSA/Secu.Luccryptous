# Luccryptous

Service API to generate and encrypt passwords.

This service is made to be public, and to encrypt passwords without having the key.


# Installation

## Build

``` shell
podman build -t luccryptous .
```


## Execution

``` shell
podman run -d -m 500m -p 3000:3000 --name luccryptous luccryptous
```

Install as a service

``` shell
podman generate systemd luccryptous > /etc/systemd/system/luccryptous.service
systemctl enable --now luccryptous
```


# Develop with Dockerfile.dev

``` shell
podman build -t luccryptous:dev -f ./Dockerfile.dev .
podman run -it --rm -m 1024m -p 5000:5000,35729:35729 -v ~/Projects/luccryptous/views/:/app/:Z --name luccryptous_dev luccryptous:dev
```


# Configuration

The configuration is in Toml file or environment variables

Create a file *luccryptous.toml* or use the example, then edit the values.


| Section             | Key             | Default | Description                                   |
|---------------------|-----------------|---------|-----------------------------------------------|
| General             | Key             |         | Encryption key, required                      |
| General             | Debug           | false   | Set to true to switch gin gonic in debug mode |
| Password Generation | size            | 42      | Size                                          |
| Password Generation | charset         | ...     | Char selection                                |
| Password Generation | check_uppercase | true    | Force password to have uppercase char         |
| Password Generation | check_lowercase | true    | Force password to have lowercase char         |
| Password Generation | check_numerics  | true    | Force password to have numerics               |
| Password Generation | check_symbols   | true    | Force password to have symbols                |


For parameters check_uppercase, check_lowercase, check_numerics and check_symbols if
related characters sets are not in the charset, those parameters are automatically
disabled.


# External dependencies

- spf13/viper
- gin-gonic
- google/uuid
