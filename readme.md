DB-Migration
=

## Requirements:

- Bash >= 4: if using macOS, you need to install if manually
- PHP >= 7
- Operating System: MAC M1 - Ventura (13)

## Informations:

- A *.load file is a file used by PgLoader to load database.

## Usage:

- Create a .env file from .env.dist. You better copy all variables to ensure the loading script will work as expected.
- Configure your connections from the .env file by setting the source 

```bash
./scripts/run-load.sh
```