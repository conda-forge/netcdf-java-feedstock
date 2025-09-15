#!/usr/bin/env bash
set -exuo pipefail

mkdir -p "$PREFIX/lib/java" "$PREFIX/bin"
cp "$SRC_DIR/toolsUI-$PKG_VERSION.jar" "$PREFIX/lib/java/toolsUI.jar"

# --------------------------------------------------------------------------
# Launchers
# --------------------------------------------------------------------------

# write_unix_launcher <file> <main-class>
write_unix_launcher() {
  local file="$1" main="$2"
  local out="${PREFIX}/bin/${file}"
  cat <<EOF > "${out}"
#!/usr/bin/env bash
set -euo pipefail
JAR="\${CONDA_PREFIX}/lib/java/toolsUI.jar"
exec java -Xms512m -Xmx4g \${JAVA_OPTS:-} -cp "\$JAR" ${main} "\$@"
EOF
  chmod +x "${out}"
}

# write_windows_launcher <file> <main-class>  (adds .bat)
write_windows_launcher() {
  local file="$1" main="$2"
  local out="${PREFIX}/bin/${file}.bat"
  cat <<EOF > "${out}"
@echo off
setlocal
set "JAR=%CONDA_PREFIX%\lib\java\toolsUI.jar"
java -Xms512m -Xmx4g %JAVA_OPTS% -cp "%JAR%" ${main} %*
exit /b %ERRORLEVEL%
EOF
  unix2dos "${out}"
}

# write_launcher <file> <main-class>  -> emits Unix + Windows launchers
write_launcher() {
  write_unix_launcher "$1" "$2"
  write_windows_launcher "$1" "$2"
}

# --------------------------------------------------------------------------
# Create launchers
# --------------------------------------------------------------------------
write_launcher ncj-toolsui        ucar.nc2.ui.ToolsUI
# netCDF-Java tools
write_launcher ncj-nccopy         ucar.nc2.write.Nccopy
write_launcher ncj-ncdump         ucar.nc2.NCdumpW
write_launcher ncj-nccompare      ucar.nc2.util.CompareNetcdf2
write_launcher ncj-bufrsplitter   ucar.nc2.iosp.bufr.writer.BufrSplitter
write_launcher ncj-cfpointwriter  ucar.nc2.ft.point.writer.CFPointWriter
write_launcher ncj-gribcdmindex   ucar.nc2.grib.collection.GribCdmIndex
write_launcher ncj-featurescan    ucar.nc2.ft2.scan.FeatureScan
write_launcher ncj-catalogcrawler thredds.client.catalog.tools.CatalogCrawler