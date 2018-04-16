CREATE OR REPLACE VIEW planet_osm_roads AS
SELECT
osm_id,
tags->'admin_level' as "admin_level",
tags->'covered' as "covered",
tags->'highway' as "highway",
tags->'name' as "name",
tags->'name:de' as "name:de",
tags->'int_name' as "int_name",
tags->'name:en' as "name:en",
tags->'railway' as "railway",
tags->'ref' as "ref",
tags->'service' as "service",
tags->'surface' as "surface",
tags->'tunnel' as "tunnel",
tags->'aerialway' as "aerialway",
tags->'addr:housenumber' as "addr:housenumber",
tags->'aeroway' as "aeroway",
tags->'amenity' as "amenity",
tags->'barrier' as "barrier",
tags->'boundary' as "boundary",
tags->'building' as "building",
tags->'historic' as "historic",
tags->'lock' as "lock",
tags->'man_made' as "man_made",
tags->'power' as "power",
tags->'route' as "route",
tags->'shop' as "shop",
tags->'waterway' as "waterway",
tags->'width' as "width",
way as way,
way_area as way_area,
z_order as z_order,
osml10n_get_placename_from_tags(tags,true,false,' - ','de',way) as localized_name_second,
osml10n_get_placename_from_tags(tags,false,false,' - ','de',way) as localized_name_first,
osml10n_get_name_without_brackets_from_tags(tags,'de',way) as localized_name_without_brackets,
osml10n_get_streetname_from_tags(tags,true,false,' - ','de', way) as localized_streetname,
COALESCE(tags->'name:hsb',tags->'name:dsb',tags->'name') as name_hrb,
layer as layer,
tags as tags,
tags->'bridge' as "bridge"
FROM planet_osm_hstore_roads;

GRANT select ON planet_osm_roads TO public;
