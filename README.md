# maposmatic-vagrant

Performs a full MapOsMatic installation in an Ubuntu "Jammy" 22.04LTS VM using Vagrant and shell provisioning

WARNING: currently not fully working due to libmapnik3.1 not being built
against the Proj library in "Jammy" due to version incompatibilities :(

## Table of contents

- [Components](#components)
- [Requirements](#requirements)
- [Installation and useage](#installation-and-useage)
- [Startup messages](#startup-messages)
- [File system layout](#file-system-layout)
  - [On the host](#on-the-host)
  - [In the VM](#in-the-vm)
- [Keeping the data up to date](#keeping-the-data-up-to-date)
- [Adding a new style or overlay](#adding-a-new-style-or-overlay)
  - [Prequisites](#prequisites)
  - [Database](#database)
  - [Shapefiles](#shapefiles)
- [Provision a real server](#provision-a-real-server)


## Components

The following components will be installed into the VM:

* OCitysMap rendering backend (from my own modified fork)
* MapOSMatic web frontend (again from my own fork)
* Stylesheets:
  * Current OSM default style
  * MapOSMatic Printable style
  * HikeBikeMap style
  * Humanitarian style (HOT)
  * MapQuest European style
  * German openstreetmap.de style
  * ... and more ...
* Overlay stylesheets:
  * Golf overlay
  * Fire Hydrant overlay
  * ... and more ...

## Requirements

* A working Vagrant (>= v2.2) / Virtualbox (>= v5.2) setup
* The `vagrant-vbguest` plugin to automatically install the host's VirtualBox Guest Additions on the guest system, install with `vagrant plugin install vagrant-vbguest` (only for VirtualBox Vagrant's provider).
* The `vagrant-disksize` plugin to grow the VMs disk space, install with `vagrant plugin install vagrant-disksize`
* Optional:  The `vagrant-cachier` plugin, to cache apt, gem, npm, pip packages, install with `vagrant plugin install vagrant-cachier`
* A minimum of 4GB available RAM, 3GB for the VM, and 1GB extra head room for the host system
* About 30GB of disk space minimum (the more the larger your OSM PBF extract import file is)
* A working internet connection 
* Sufficient bandwidth, about 4GB of data will be downloaded during installation and provisioning 

## Installation and useage

* Copy a OSM PBF extract of your choice into this directory. If multiple files with ending '.pbf' are found only the first one is used. 
* Run `vagrant up`
* Be patient ...
  * The stylesheets require quite some extra downloads, and some processing on these (shape files, height information, ...). The downloads are cached localy, so downloads only happens on the first start mostly
  * Importing the provided OSM PBF file can take some time, too, depending on its size ...
* When the VM starts to test the different style sheets and overlays it is actually already ready to use.
  * You can access the web interface on http://localhost:8000/
  * Or you can log into the VM with `vagrant ssh`, e.g. to run the command line renderer directly or to do actual development work

## Startup messages

The provisioning scripts will produce a lot of output when the VM
is started for the first time.

Everything that is printed in green is just progress info and can
easily be ignored.

Red output may be more serious, but unfortunately some tools print
their progress messages to standard error output, too, so some red
output can't be avoided.

Red things that can be ignored are:

* everything starting with `NOTICE:`
* lines starting with `warning:` in the "pghyghtmap" secition
* everything in the "DB IMPORT" section, unless there's an actual error messages at the end of the red block
* `ERROR:  "planet_osm_point" is not a table or materialized view` in the "OpenRailwayMap" style block
* everything in the "WAYMARKED" section as long as all data up to `Importing slopes DB` gets processed
* npn `WARN` messages in the "DJ FRONTEND" section
* everything in the 'OSM_Notes_Overlay' section for now (it needs fixing on my side, but won't affect the other map styles

## File system layout

### On the host 

<dl>
  <dt>Vagrantfile</dt>
  <dd>Main virtual machine setup file</dd>
  
  <dt>provision.sh</dt>
  <dd>Top level provisioning script, executes all scripts found in the inc/ folder</dd>
  
  <dt>cache/</dt>
  <dd>Used for cacheing downloads</dd>
  
  <dt>files/</dt>
  <dd>Contains extra files needed by the provisioning scripts</dd>
  
  <dt>inc/</dt>
  <dd>Contains all the provisioning shell scripts</dd>
  
  <dt>inc/styles/</dt>
  <dd>Provisioning scripts and ocitysmap ini file snippets for map styles</dd>
  
  <dt>inc/overlays/</dt>
  <dd>Provisioning scripts and ocitysmap ini file snippets for map overlays</dd>
  
  <dt>test</dt>
  <dd>Shared folder for running render tests in the VM and have results visible on the host</dd>
</dl>

### In the VM

Inside the VM almost everything gets installed under the `/home/maposmatic` directory.

<dl>
  <dt>elevation-data</dt>
  <dd>Ditigal elevation model data for hillshadings and reliefs</dd>
  
  <dt>ocitysmap</dt>
  <dd>The MapOSMatic OCitysMap renderer</dd>
  
  <dt>maposmatic</dt>
  <dd>The MapOSMatic web frontend</dd>

  <dt>osmosis-diffimport</dt>
  <dd>Data dir for OSM diff imports to update the databasse</dd>
  
  <dt>shapefiles</dt>
  <dd>All shapefiles required by the different map styles installed</dd>

  <dt>styles</dt>
  <dd>All installed mapstyles are here, with the exception of the maposmatic-printable style which is part of the ocitysmap renderer repository</dd>

  <dt>tools</dt>
  <dd>All tools that need to be installed from source</dd>

  <dt>umgebungsplaene</dt>
  <dd>The neighbourhood maps project, an alternative frontend to the MapOSMatic rendering service</dd>
</dl>

## Keeping the data up to date

If the OSM PBF file you used for the initial data import provides
a replication base URL to fetch diffs from, a systemd service 
will be set up to download such diff files and to apply the changes
to the database.

E.g. GeoFabrik provides daily diff files for all their regional extracts,
so if you downloaded the PBF file used for initial setup from there
your databases can be brought up to date with

```bash
  systemctl start osm2pgsql-update.service
  systemctl start waymarked-update.service
```

If you want to import updates on a daily basis automatically you
can enable the systemd timer that also got installed for this service:

```bash
  systemctl enable osm2pgsql-update.timer
  systemctl start  osm2pgsql-update.timer

  systemctl enable waymarked-update.timer
  systemctl start  waymarked-update.timer
```

This will run the diff update services once per day each, or whenever the
VM is restarted.

If no `replication_base_url` information is found in the initial import
file, then the service unit and timer will not be installed at all. 

(This unfortunately is also true for full planet files at this point, 
but I don't expect anyone to try a full planet import inside a VM anyway. 
If you actually *do* plan to do this, please let me (<hartmut@php.net>) 
know and I'll see what I can work out to support automatic diff import 
setup for this, too)

Also the shapefiles can be updated every once in a while. This does not
depend on the import file used, so the service and timer files for this
are always installed. You can start the shapefile update service manually
with

```bash
  systemctl start shapefile-update.service
```

or enable daily automatic updates with

```bash
  systemctl enable shapefile-update.timer
  systemctl start  shapefile-update.timer
```

## Adding a new style or overlay

### Prequisites

* needs to be Mapnik XML, or a format that can be converted into that, like CartoCSS
* needs to use the "osm2pgsql" database schema (e.g. the "imposm" schema is not supported)

### Database

The setup uses the ``--hstore-only`` approach to import the OSM data into PostGIS,
meaning that all OSM attributes are stored in a hstore column `tags` only. Most styles
expect to have explicit feature columns in tables like `planet_osm_polygon` though.

To support this, and to be able to add new feature columns on short notice withough
having to rebuild tables, the hstore-only tables created at import time are actually
named `planet_osm_hstore_polygon` etc.

The actual `planet_osm_%` tables are then implemented as views instead, mapping specific
`tags` hstore entries to view columns. This model is used by the German OSM style by
default, and can easily be adapted to other styles, too, as the fact that they are
actually reading from views and not from the actual tables is totally transparent to 
them.

If the style you want to add uses feature columns not present in the views yet, 
you can easily add them to the view declaration and re-import just that.

E.g. if you need to add a column named `atm` to the `planet_osm_point` table
for a banking related style, open the `files/database/db_views/planet-osm-point.sql` 
file, and add this at the end of the view definition, right above the `FROM` line:

```sql
CREATE OR REPLACE VIEW planet_osm_point AS
SELECT osm_id
[...]
, tags->'wetland' as "wetland"
-- after initial import add further columns below this line only
, tags->'atm' as "atm" --   <-- this line added by you
FROM planet_osm_hstore_point;
[...]
```

The inside the VM, run:

```bash
  sudo -u maposmatic psql gis < /vagrant/files/database/db_views/planet-osm-point.sql
```

to modify the view.

Adding at the end is necessary when replacing the view, as there may already
be other views added by other styeles that rely on this views column order.
When you add your new column before the initial import, or plan to do a re-import,
you can as well add the new column at the right sorting position right away.

### Shapefiles

Shapefiles are stored under `/home/maposmatic/shapefiles/` to avoid duplicate
download bandwidth and storage space. 

Try to create symlinks from there to the path your style expects the shapefiles
in, or modify the paths in the style righ away to point to the central shapefile
directory.

If your style needs a shapefile not yet present, consider adding it to the 
`inc/get-shapefiles.sh` script by adding a line like

```bash
  URLS+="http://example.com/path/to/some-shapefile.zip"
```

and re-run the script with

```bash
  /vagrant/inc/get-shapefiles.sh
```

This will check for all shapefile archives that have not been downloaded yet,
or which have change since last downloaded, to download and install these under
`/home/maposmatic/shapefiles/` 

## Provision a real server

You can also use the provisioning scripts from this project to set up a real
server instance instead of a Vagrant VM, although it's still a little bit 
'hacky' to do so. Also this will only work on a Ubuntu 18.04LTS system.

As for now the `/vagrant` and `/home/maposmatic` base paths are still
hard coded into several of the provisioning scripts you have to check out
the project into directory `/vagrant`, put a PBF file to import there,
and then run the master provisioning script manually:

```bash
  git clone https://github.com/hholzgra/maposmatic-vagrant/ /vagrant
  cd /vagrant
  ... copy, symlink or download .osm.pbf file to this director ...
  bash provision.sh
```
