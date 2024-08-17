CREATE INDEX planet_osm_hstore_polygon_signal_box 
    ON planet_osm_hstore_polygon using GIST(way) 
 WHERE (tags->'railway' = 'signal_box');

CREATE INDEX planet_osm_hstore_polygon_railway
    ON planet_osm_hstore_polygon using GIST(way) 
 WHERE (tags->'railway' IS NOT NULL);

