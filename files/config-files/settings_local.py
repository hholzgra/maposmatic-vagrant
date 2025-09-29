#!/usr/bin/env python
# coding: utf-8

# maposmatic, the web front-end of the MapOSMatic city map generation system
# Copyright (C) 2009  David Decotigny
# Copyright (C) 2009  Frédéric Lehobey
# Copyright (C) 2009  David Mentré
# Copyright (C) 2009  Maxime Petazzoni
# Copyright (C) 2009  Thomas Petazzoni
# Copyright (C) 2009  Gaël Utard

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
Copy this template into www/settings_local.py. Remove comment and edit
to your needs. You can add specific Django settings if needed:
https://docs.djangoproject.com/en/1.8/ref/settings/
"""

# # Allow to contact under this address
ALLOWED_HOSTS = ['*']

# # Contact email
CONTACT_EMAIL = "hartmut@php.net"

# # Make this unique, and don't share it with anybody.
SECRET_KEY = 'tm+wb)lp5q%br=p0d2toz&km_-w)cmcelv!7inons&^v9(q!d2'

# # If you want to provide extra information in the footer put it in EXTRA_FOOTER
# EXTRA_FOOTER = ""

import sys

OCITYSMAP_PATH= '@INSTALLDIR@/ocitysmap'
sys.path.append(OCITYSMAP_PATH)


# # Debug mode. Set to False on a production environnement
DEBUG = True

# # With DEBUG set to False error will be set to the following emails
ADMINS = (
    ('MapOSMatic admin', 'hartmut@php.net'),
)

# # By default an SQLite DB is set. It is only relevant for testing purpose.
# # You should use MySQL or PostgreSQL on production. Check Django doc:
# # https://docs.djangoproject.com/fr/1.10/ref/settings/#databases
# import os
# DATABASES = {
#     # For PostgreSQL:
#     'default': {
#        'ENGINE': 'django.db.backends.postgresql',
#        'NAME': 'maposmatic',
#        'USER': 'maposmatic',
#        'PASSWORD': 'secret',
#        'HOST': 'localhost',
#        'PORT': '5432'
#        },
#
# }
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'maposmatic',
        'USER': 'maposmatic',
        'PASSWORD': 'secret',
        'HOST': 'gis-db',
        'PORT': '5432'
        },
    'osm': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'gis',
        'USER': 'maposmatic',
        'PASSWORD': 'secret',
        'HOST': 'gis-db',
        'PORT': '5432'
        },
    'osm5': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'osmcarto5',
        'USER': 'maposmatic',
        'PASSWORD': 'secret',
        'HOST': 'gis-db',
        'PORT': '5432'
        },
    'waymarked': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'planet',
        'USER': 'maposmatic',
        'PASSWORD': 'secret',
        'HOST': 'gis-db',
        'PORT': '5432'
        },
}

# # Path to ocitysmap's config file to use, or None for the default
# # (~/.ocitysmap.conf)
OCITYSMAP_CFG_PATH = '@INSTALLDIR@/.ocitysmap.conf'

RENDERING_RESULT_PATH = '@DATADIR@/rendered_maps/'
RENDERING_RESULT_URL = '/results/' # Either a relative URL or an absolute URL
RENDERING_RESULT_FORMATS = ['png', 'svgz', 'pdf', 'csv']
RENDERING_RESULT_MAX_SIZE_GB = 10
RENDERING_RESULT_MAX_PURGE_ITERATIONS = 10

# # Default output log file when env variable MAPOSMATIC_LOG_FILE is not set
DEFAULT_MAPOSMATIC_LOG_FILE = '@LOGDIR@/maposmatic.log'

# # Default log level when the env variable DEFAULT_MAPOSMATIC_LOG_LEVEL
# # is not set
import logging
DEFAULT_MAPOSMATIC_LOG_LEVEL = logging.INFO
DEFAULT_MAPOSMATIC_LOG_FORMAT = "%(asctime)s - %(name)s@%(process)d - "\
                                "%(levelname)s - %(message)s"

# paper size limits in millimeters
PAPER_WIDTH_MIN  =  100
PAPER_HEIGHT_MIN =  100
PAPER_WIDTH_MAX  = 2000
PAPER_HEIGHT_MAX = 2000

# # Base bounding box
BASE_BOUNDING_BOX = (51.7, 7.5, 52.2, 9.5)

# Restrict map rendering to this bounding box
# Set to False on full planet setups or if
# you don't care to get back maps with no data
MAX_BOUNDING_BOX = False

# geojson multipolygon for the area *not*
# covered by the data import
# this area will be grayed out on the slippy map
OUTER_BOUNDS_JSON = False

# # Maximum length of the bounding box to be rendered. This length is
# # checked in both directions (longitude and latitude).
# # Note: if you change this you should probably change
# # BBOX_MAXIMUM_LENGTH_IN_KM in osm_map.js too.
BBOX_MAXIMUM_LENGTH_IN_METERS = 20000

# # Number of items displayed per page in the jobs and maps pages
ITEMS_PER_PAGE = 25

# # PID file location for the rendering daemon associated with this
# # instance; normally managed by the /etc/init.d scripts such as
# # start-stop-daemon(8) in debian systems:
MAPOSMATIC_PID_FILE = '/var/run/maposmaticd.pid'

# Feed URL for the RRS feed on the front page
MAPOSMATIC_RSS_FEED = 'http://blog.get-map.org/index.php/feed/?cat=2'

# # Settings for exception emails: the from email address, and the list of
# # receipient email addresses. No emails are sent if the SMTP host is not
# # defined.
DAEMON_ERRORS_SMTP_HOST = None
DAEMON_ERRORS_SMTP_PORT = 25
DAEMON_ERRORS_EMAIL_FROM = 'daemon@domain.com'
DAEMON_ERRORS_EMAIL_REPLY_TO = 'noreply@domain.com'
DAEMON_ERRORS_JOB_URL = 'http://domain.com/jobs/%d'
DAEMON_ERRORS_SMTP_ENCRYPT = False
DAEMON_ERRORS_SMTP_USER = ''
DAEMON_ERRORS_SMTP_PASSWORD = ''

EMAIL_HOST          = False; # "mail.example.org"
EMAIL_HOST_USER     = "..."
EMAIL_HOST_PASSWORD = "..."

# # Show a link to donate to the MapOSMatic team
MAPOSMATIC_DONATION = False

# # Displayed on the top menu
BRAND_NAME = "MyOSMatic"
# # Front page feed
FRONT_PAGE_FEED = "https://blog.get-map.org/index.php/feed/"


# # Alert message (for instance for maintenance announce)
# ALERT_MESSAGE = ""

# # To respect the AGPL licence proper links to source code must be
# # displayed
MAPOSMATIC_FORK_URL = "https://github.com/hholzgra/maposmatic"
OCITYSMAP_FORK_URL = "https://githib.com/hholzgra/ocitysmap"

# root directory for uploaded files etc.
MEDIA_ROOT = '@DATADIR@'

# we changed encoding of map titles in file names at some point, this is the
# last ID using the old scheme so that links to old files still work
# for fresh setups it can always be zero
LAST_OLD_ID = 0

# put a PayPal "hosted_button_id" here to enable the donation page
# see also: https://developer.paypal.com/docs/integration/web/
# e.g.   PAYPAL_ID = 'YQPBAUM3JW8T2'  # original MapOSMatic doation ID
PAYPAL_ID = ''

# Piwik base URL - enable tracking if set
# exclude http:/https:, this will be added dynamically
# example: PIWIK_BASE_URL = '//stats.maposmatic.org/piwik/'

PIWIK_BASE_URL = ''

# how long to store the submitter IP address in the database
# value in hours, 0 for no storage at all, -1 for unlimited
# storage without purging
SUBMITTER_IP_LIFETIME=24

# how many hours to store the optonal submitter IP address in
# the database after the related rendering job finished
# set to 0 to keep them forever
SUBMITTER_MAIL_LIFETIME=24

# Upload file lifetime in days, set to 0 for "forever"
UPLOAD_FILE_LIFETIME=365

# Weblate base URL - link to translation service
WEBLATE_BASE_URL = 'https://translate.get-map.org/'

# contact information, to be displayed in page footer if set
CONTACT_EMAIL = 'hartmut@php.net'
CONTACT_CHAT  = 'irc://irc.freenode.net/#maposmatic'


# custom branding
EXTRA_FOOTER = 'Generated by MapOSMatic-Vagrant testing instance'
EXTRA_LOGO   = 'bundled:FOSSGIS_Logo.svg'
EXTRA_IP     = '10.0.2.2'


# show this in a warning box on top of the page when set
MAINTENANCE_NOTICE = ''

