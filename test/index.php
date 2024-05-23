<?php

function timecomp($d1, $d2)
{
    if (empty($d1["time"]) || empty($d2["time"])) return 0;

    return strcmp($d2["time"], $d1["time"]);
}

$results=[];
$formats=[];
$runlist=[];

foreach (glob("test-*.sh") as $file) {
    if (preg_match('|^test-(\w+)-([-\w]+)-(\w+)\.sh$|', $file, $m)) {
        list($name, $type, $style, $format) = $m;

        $formats[$format] = $format;
        
        $base = "test-$type-$style-$format";
        $ext  = ($format === "multi") ? "pdf" : $format;

        $running = file_exists( $base.".running");

        $result  = $base.".".$ext;
        $log     = $base.($running ? ".log" : ".err");
                 
        $time = NULL;
        $status = "unknown";
        if ($running) {
            $status = "running";
            $time = strftime("%T", time() - filemtime("$base.running"));
        } else if(file_exists($base.".time")) {
            $status = file_exists($base.".".$ext) ? "success" : "failed";
            $time = trim(file_get_contents($base.".time"));
        }

        $data = [
            "base"    => $base,
            "type"    => $type,
            "style"   => $style,
            "format"  => $format,
            "ext"     >= $ext,
            "running" => $running,
            "time"    => $time,
            "result"  => $result,
            "log"     => "read.php?name=".urlencode($log),
            "status"  => $status,
        ];

        if (!isset($results[$type])) {
            $results[$type] = array();
        }
        if (!isset($results[$type][$style])) {
            $results[$type][$style] = array();
        }
        if (!isset($results[$type][$style][$format])) {
            $results[$type][$style][$format] = array();
        }

        $results[$type][$style][$format] = $data;
        if ($status == "running") {
            $runlist[$base] = $data;
        }
    }
}

if (count($runlist)) {
    header("Refresh: 10\n");
}
?>
<html>
<head><title>Test Results</title></head>
<body>
<a href="thumbnails/">Thumbnails</a>
-
<a href="all-styles.pdf">all styles in a PDF book</a>
-
<a href="all-styles-poster.pdf">all styles on poster size pages</a>
-
<a href="all-overlays-poster.pdf">all overlays on poster size pages</a>
<hr/>
    <table border='1'>
    <tr valign='top'>
<?php if (count($runlist)) { ?>
<td style='padding: 15px; spacing:15px'>
<h3>Running:</h2>
<table>
  <tr><th>Test</th><th>Time</th></tr>
<?php
uasort($runlist, "timecomp");
foreach ($runlist as $name => $data) {
echo
    "<tr><td>".$data["style"]." - ".$data["format"]."</td><td><a target='_blank' href='".$data["log"]."'>".$data["time"]."</a></td></tr>\n";
} 
?>
</table>
<?php } ?>
<?php
foreach ($results as $type => $styles) {
  echo "</td><td style='padding: 15px; spacing:15px'>\n";

  echo "<h3>$type</h3>\n";
  echo "<table>\n";
  echo "  <tr><th>Test</th>";
  foreach ($formats as $format) {
      echo "<th>$format</th>";
  }
  echo "</tr>\n";
  foreach ($styles as $name => $style) {
      echo "  <tr><td>$name</td>";
      foreach ($formats as $format) {
         if (isset($style[$format])) {
           $data = $style[$format];
           switch($data["status"]) {
             case "running": $color = "yellow"; break;
             case "success": $color = "lightgreen"; break;
             case "failed" : $color = "orangered"; break;
             default: $color = "white"; break;
           }
           echo "<td align='right' bgcolor='$color'><a target='_blank' href=".$data["log"].">".$data["time"]."</a></td>";
         } else {
             echo "<td>&nbsp;</td>";
         }
      }
      echo "</tr>\n";
  }
  echo "</table>\n";
}
?>
    </td></tr></table>
</body>
</html>
