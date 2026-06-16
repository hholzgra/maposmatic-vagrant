#! /bin/env python3

import os, sys

# TODO find a cleaner way for this
sys.path.append(os.path.join(os.environ.get('INSTALLDIR', '/home/maposmatic'), 'ocitysmap'))

from ocitysmap import OCitySMap

def gen_deps(prefix, styles):
    for style in styles:
        print()
        print(".PHONY: %s" % style)
        print("%s:" % style, end = "")
        for format in [ 'png', 'pdf', 'svgz', 'multi.pdf' ]:
            print(" %s/%s.%s" % (prefix, style, format), end = "")
        print()

if len(sys.argv) > 1:
    oc = OCitySMap(config_files = sys.argv[1:])
else:
    oc = OCitySMap()

styles = oc.get_all_style_names()
print()
print("# Styles")
print()
print("ALL_STYLES = %s" % " ".join(styles))
gen_deps("styles", styles)
print()

overlays = oc.get_all_overlay_names()
print()
print("# Overlays")
print()
print("ALL_OVERLAYS = %s" % " ".join(overlays))
gen_deps("overlays", oc.get_all_overlay_names())
print()
