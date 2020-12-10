rm(list = ls())
# List all packages needed for session
neededPackages = c("ggplot2","dplyr","sf") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)


# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

sfpAll <- st_read("Shapefiles/sfpAll.shp")

g <- ggplot(sfpAll) +
  geom_sf(color = NA,fill = "lightgreen")

ggsave(g,"_outputs/maps/test.pdf")

maluku <- raster::raster("Shapefiles/Margono/margono_primary_forest_Maluku_reclassified.tif")
papua <- raster::raster("Shapefiles/Margono/margono_primary_forest_Papua_reclassified.tif")

maluku_papua <- raster::merge(maluku,papua)

raster::writeRaster(maluku_papua,"Shapefiles/Margono/maluku_papua.tif")
