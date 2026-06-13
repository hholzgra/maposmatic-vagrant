# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A Vagrant-based automated provisioning system that installs a full [MapOSMatic](https://github.com/hholzgra/maposmatic) city map generation stack into a Debian Bookworm VM. The host directory is mounted read-only at `/vagrant` inside the VM; all installed software lives under `/home/maposmatic` in the VM.

The two main upstream repos this provisions are:
- **OCitysMap** (`/home/maposmatic/ocitysmap`) — rendering backend (Python, Mapnik)
- **MapOSMatic** (`/home/maposmatic/maposmatic`) — Django web frontend

## Starting and provisioning the VM

```bash
# Copy a .pbf extract into the repo root first, then:
vagrant up                  # first run: full provisioning (~hours)
vagrant up --provision      # re-run provisioning on existing VM
vagrant ssh                 # log in
vagrant halt                # stop VM
```

Port forwards (host → VM): `8000→80` (MapOSMatic), `8080→8080` (Weblate), `8090→8090` (uMap).

## Local configuration

Copy `local-config.sh-dist` to `local-config.sh` (gitignored) and edit to control optional components:

```bash
WITH_WEBLATE=NO       # default NO in local-config.sh
WITH_TILESERVER=NO    # default NO
WITH_UMAP=NO          # default NO (not in dist)
```

The `.env` file (also gitignored) is loaded by the `vagrant-env` plugin if installed.

## Provisioning script architecture

`provision.sh` is the top-level script. It sources scripts from `inc/` in order:

| Script | Purpose |
|--------|---------|
| `inc/install-packages.sh` | apt, pip, gem, npm packages + fonts |
| `inc/get-shapefiles.sh` | Download/cache shapefiles to `cache/shapefiles/`, install under `/home/maposmatic/shapefiles/` |
| `inc/database-setup.sh` | PostgreSQL + PostGIS setup; databases: `gis`, `osm2pgsql_flex`, `maposmatic` |
| `inc/osm2pgsql-import.sh` | Classic osm2pgsql import into `gis` DB (hstore-only: `planet_osm_hstore_*` tables, with views as `planet_osm_*`) |
| `inc/osm2pgsql-import-flex.sh` | Flex-mode import into `osm2pgsql_flex` DB |
| `inc/elevation-data.sh` | Download DEM data for hillshading/contours |
| `inc/ocitysmap.sh` | Clone and configure OCitysMap renderer |
| `inc/styles.sh` | Install all map styles and overlays, then generate `.ocitysmap.conf` |
| `inc/maposmatic-frontend.sh` | Clone and configure MapOSMatic Django app + Apache |

All scripts write `export VAR=value` entries to `/etc/profile.d/mapospatic.sh` so the same variables (`INSTALLDIR`, `INCDIR`, `STYLEDIR`, `SHAPEFILE_DIR`, `CACHEDIR`, `OSM_EXTRACT`) are available when re-running scripts manually inside the VM.

## Adding a map style

1. Create `inc/styles/<name>.sh` — clone the style repo into `$STYLEDIR/<name>`, compile CartoCSS to XML if needed (`carto --api 3.0.32 project.mml > style.xml`), apply any patches.
2. Create `inc/styles/<name>.ini` — OCitysMap config snippet with `[style_id]`, `name=`, `path=`, etc. Use `@STYLEDIR@` and `@INSTALLDIR@` as placeholders; they are substituted by `ocitysmap-conf.sh`.
3. Optionally create `inc/styles/<name>.db` for any database setup the style needs.

Overlays follow the same pattern under `inc/overlays/`.

## Database schema note

The `gis` database uses **hstore-only** import: raw tables are `planet_osm_hstore_{point,line,polygon,roads}`. Standard `planet_osm_*` names are **views** defined in `files/database/db_views/` that extract specific tags as columns. To add a new column for a style:

```bash
# edit files/database/db_views/planet-osm-point.sql
# add: , tags->'new_key' as "new_key"   above the FROM line
sudo -u maposmatic psql gis < /vagrant/files/database/db_views/planet-osm-point.sql
```

## Re-running individual scripts inside the VM

After `vagrant ssh`, environment variables are pre-set and the Python virtualenv is activated:

```bash
# re-run shapefile download
/vagrant/inc/get-shapefiles.sh

# re-run a specific style install
source /vagrant/inc/styles/baumkarte.sh

# regenerate ocitysmap config
source /vagrant/inc/ocitysmap-conf.sh

# OSM data updates (if replication URL available in original PBF)
systemctl start osm2pgsql-update.service
systemctl start waymarked-update.service
```

## Render tests

Test scripts and results live in `test/` (shared folder, writable from both host and VM):

```bash
# inside the VM:
cd /vagrant/test
./run-tests.sh
```

Results appear in `test/` and `test/thumbnails/` and are accessible from the host.

## Config file template substitution

Several files in `files/config-files/` contain `@INSTALLDIR@`, `@INCDIR@`, `@LOGDIR@`, `@DATADIR@` placeholders. These are substituted with `sed` during provisioning before being copied to their destinations. When editing these templates, use the same placeholder syntax.

## Databases and credentials (VM-internal, dev-only)

- PostgreSQL user: `maposmatic`, password: `secret`
- Databases: `gis` (classic import), `osm2pgsql_flex` (flex import), `maposmatic` (Django), `planet` (Waymarked Trails)
- DB host alias: `gis-db` (points to `localhost` via `/etc/hosts`)
- Django admin: user `admin`, password `secret`
- Web frontend: http://localhost:8000/ (from host)
