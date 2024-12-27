import json

geojson_file = "westen.umap"

with open(geojson_file, 'r') as geojson:
    xcoords = []
    ycoords = []
    data = json.load(geojson)
    for l in data['layers']:
        print("l")
        for f in l['features']:
            print("f")
            geom = f['geometry']
            for coord in geom['coordinates']:
                if type(coord) == float:  # then its a point feature
                    xcoords.append(geom['coordinates'][0])
                    ycoords.append(geom['coordinates'][1])
                elif type(coord) == list:
                    for c in coord:
                        if type(c) == float:  # then its a linestring feature
                            xcoords.append(coord[0])
                            ycoords.append(coord[1])
                        elif type(c) == list:  # then its a polygon feature
                            xcoords.append(c[0])
                            ycoords.append(c[1])

    extent = [
        [min(ycoords), min(xcoords)],
        [max(ycoords), min(xcoords)],
        [max(ycoords), max(xcoords)],
        [min(ycoords), max(xcoords)]
    ]

    print(extent)
