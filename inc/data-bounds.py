#!/usr/bin/python3
import os
import sys
import psycopg2
import re
import json
import subprocess

conn = psycopg2.connect(host="127.0.0.1", database="gis", user="maposmatic", password="secret")

boundsdir = sys.argv[1]
pbf_file  = sys.argv[2]

if not os.path.exists(boundsdir):
    os.mkdir(boundsdir)
os.chdir(boundsdir)

if not os.path.exists(pbf_file):
    print("PBF file not found")
    exit(3)

result = subprocess.run(['osmium', 'fileinfo', '-j', pbf_file], stdout=subprocess.PIPE)

pbf = result.stdout

pbf_json = json.loads(pbf)

try:
    bbox = pbf_json['header']['boxes'][0]

except:
    print("Failed to read bounding box from file headers, falling back on searching all points in the file")

    result = subprocess.run(['osmium', 'fileinfo', '-e', '-j', pbf_file], stdout=subprocess.PIPE)

    pbf = result.stdout

    pbf_json = json.loads(pbf)

    bbox = pbf_json['data']['bbox']



with open("bbox.wkt", 'w') as f:
    f.write("BOX(%s %s, %s %s)\n" % (bbox[0], bbox[1], bbox[2], bbox[3]))

with open("bbox.bash", 'w') as f:
    f.write('(%s %s %s %s)\n' % (bbox[0], bbox[1], bbox[2], bbox[3]))

with open("bbox.py", 'w') as f:
    f.write('MAX_BOUNDING_BOX = (%s, %s, %s, %s)\n' % (bbox[1], bbox[0], bbox[3], bbox[2]))

js = { '_northEast': { 'lon': float(bbox[2]), 'lat': float(bbox[3]) },
       '_southWest': { 'lon': float(bbox[0]), 'lat': float(bbox[1]) }}

with open("bbox.json", 'w') as f:
    json.dump(js, f, indent=2)

bbox_str = "%s, %s, %s, %s" % (bbox[0], bbox[1], bbox[2], bbox[3])

try:
    query = """
    SELECT st_xmin(poly)
         , st_ymin(poly)
         , st_xmax(poly)
         , st_ymax(poly)
         , osm_id
      FROM (
          SELECT name
               , way
               , osm_id
               , st_transform(st_simplify(way, 100),4326) as poly
            FROM planet_osm_polygon
           WHERE boundary='administrative'
        ORDER BY st_area(st_intersection(st_transform(way,4326),st_makeenvelope(%s, 4326))) DESC
           LIMIT 1
      ) a
    """ % bbox_str

    cur = conn.cursor()
    cur.execute(query)
    row = cur.fetchone()
    cur.close()

    osm_id = row[4]

    bbox_width  = float(bbox[2]) - float(bbox[0])
    bbox_height = float(bbox[3]) - float(bbox[1])

    row_width  = float(row[2]) - float(row[0])
    row_height = float(row[3]) - float(row[1])

    width_factor  = row_width / bbox_width
    height_factor = row_height / bbox_height


    if width_factor < 0.75 or height_factor < 0.75 or width_factor > 1.1 or height_factor > 1.1:
        query = """
    SELECT st_asgeojson(st_makeenvelope(%s, 4326))
         , st_asgeojson(st_difference(st_geomfromtext('Polygon((-180 90, 180 90, 180 -90, -180 -90, -180 90))', 4326), st_makeenvelope(%s, 4326)))
    """ % (bbox_str, bbox_str)
    else:
        query = """
    SELECT st_asgeojson(st_transform(st_simplify(way, 100), 4326))
         , st_asgeojson(st_difference(st_geomfromtext('Polygon((-180 90, 180 90, 180 -90, -180 -90, -180 90))', 4326), st_transform(st_simplify(way, 100), 4326)))
      FROM planet_osm_polygon
     WHERE osm_id = %s
    """ % osm_id

    cur = conn.cursor()
    cur.execute(query)
    row = cur.fetchone()
    cur.close()

    with open("inner.json", 'w') as f:
        f.write(row[0])

    with open("outer.json", 'w') as f:
        f.write(row[1])

except:
    with open("inner.json", 'w') as f:
        json.dump(js, f, indent=2)
    with open("outer.json", 'w') as f:
        json.dump(js, f, indent=2)
    
