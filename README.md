# Readme - Data and Code
**Paper:** No deforestation reductions from roll-out of community land tenure in Indonesia yet
**Authors:** Sebastian Kraus, Jacqueline Liu, Nicolas Koch, and Sabine Fuss

The code in this replication package constructs the analysis files from the two main data sources (KLHK, 2020; Hansen et al, 2013; Margono ) using Google Earth Engine, R and Stata. The main table can be generated with the file `code/analysis/mainTable.do`. The main map is built with the QGIS file `mainMap.qgz`. 

Files to construct the analysis dataset can be found in `code/build`. Deforestation data is merged to study area polygons with [this script](https://code.earthengine.google.com/ecf52ed8c490481ca7f024ee4a090512) on Google Earth Engine.

There is no master file to run the whole repository at once yet. This will be included in the next iteration.
