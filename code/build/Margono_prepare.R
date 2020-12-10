### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
#### Prepare primary forest map ####    
rm(list = ls())

# List all packages needed for session"foreign",
neededPackages = c("snow","dplyr","sf","raster","rgdal","gdalUtils") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
        missingIDX = which(allPackages == FALSE)
        needed     = neededPackages[missingIDX]
        lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

IslandS <- c("Sumatra", "Kalimantan", "Papua","Sulawesi","Java","Bali_Nusa_Tenggara","Maluku")
# IslandS <- c("Bali Nusa Tenggara","Maluku","Sulawesi","Java")

for (i in 1:length(IslandS)) {
        islandN <- IslandS[i]
        aoi <- st_read("Shapefiles/Admin_areas/islands/islands.shp") %>% filter(island == islandN)
        aoi_sp <- as(aoi, 'Spatial')
        
        ### Primary forest extent map is downloaded from https://glad.umd.edu/dataset/primary-forest-cover-loss-indonesia-2000-2012
        pf <- raster(file.path("C:/Users/kras/Downloads/change/change/timeseq_change00_12.tif"))
        # Note: there is something strange with this raster, its min value is 1, while it should be 0, according to the readme attached to the file.
        # However, 
        # spf <- sampleRegular(pf, size = 1e6)
        # spf %>% as.vector() %>%  unique() 
        # shows that 0 is a value from the raster. 
        ### Crop to gfc-island extent first
        aoi_sp_prj <- spTransform(aoi_sp, crs(pf))
        crop(pf, y = aoi_sp_prj,
             filename = file.path(paste0("C:/Users/kras/Downloads/change/change/temp/margono_primary_forest_",islandN,".tif")),
             datatype = "INT1U",
             overwrite = TRUE)
        # no need to expend here, as for ioppm, because pf already completely covers aoi_sp_prj *
        rm(aoi_sp_prj)
        ### Reclassify primary forest map
        # read the island-croped pf map 
        pf <- raster(file.path(paste0("C:/Users/kras/Downloads/change/change/temp/margono_primary_forest_",islandN,".tif")))
        # The values in Margono et al. data have the following interpretation:
        # 0   - Out of area study
        # 1   - No change of primary degraded forest from 2000-2012 
        # 2   - No change of primary intact forest from 2000-2012
        # 3   - No change of non-primary from 2000-2012
        # 4   - Primary intact, cleared 2005
        # 5   - Primary intact, cleared 2010
        # 6   - Primary intact, cleared 2012 
        # 7   - Primary intact, degraded 2005
        # 8   - Primary intact, degraded 2010
        # 9   - Primary intact, degraded 2012
        # 10 - Primary degraded, cleared 2005
        # 11 - Primary degraded, cleared 2010 
        # 12 - Primary degraded, cleared 2012 
        # 13 - Primary intact degraded 2005, cleared 2010
        # 14 - Primary intact degraded 2005, cleared 2012
        # 15 - Primary intact degraded 2010, cleared 2012
        # 
        # Here, we do not care when each type of forest was degraded. 
        # The only classes that are not primary forest in 2000 are
        # 0 - Out of area study 
        # 3   - No change of non-primary from 2000-2012
        # The intact classes are 2, 4-9, 13-15
        # The degraded classes are 1, 10-12
        # Therefore the reclassification matrix is 
        m <- c(0,0,0, 
               0,1,2,
               1,2,1,
               2,3,0, 
               3,9,1,
               9,12,2,
               12,15,1)
        rclmat <- matrix(m, ncol = 3, byrow = TRUE)
        # Reclassify primary forest classes in a cluster framework
        # The two first columns of rclmat are intervals, values within which should be converted in the third column's value.
        # The right = TRUE (the default) means that intervals are open on the left and closed on the right. 
        # include.lowest means that the lowest interval is closed on the left. 
        beginCluster() # this uses by default detectCores() - 1
        clusterR(pf,
                 fun = reclassify,
                 args = list(rcl = rclmat, right = T, include.lowest = TRUE), 
                 #export = "rclmat", # works with or without 
                 filename = file.path(paste0("Shapefiles/Margono/margono_primary_forest_",islandN,"_reclassified.tif")), 
                 datatype = "INT1U",
                 overwrite = TRUE)
        endCluster()
}


# Stitching tifs back together

# IslandS <- c("Sumatra", "Kalimantan", "Papua","Sulawesi","Java","Bali_Nusa_Tenggara","Maluku")
# 
# aoi <- st_read("Shapefiles/Admin_areas/islands/islands.shp")
# 
# for (i in 1:length(IslandS)) {
#         islandN <- IslandS[i]
#         raster <- paste0("Shapefiles/Margono/margono_primary_forest_",islandN,"_reclassified.tif")
# }

rasterSumatra <- raster('Shapefiles/Margono/_old/margono_primary_forest_Sumatra_reclassified.tif')
rasterKalimantan <- raster('Shapefiles/Margono/_old/margono_primary_forest_Kalimantan_reclassified.tif')
rasterPapua <- raster('Shapefiles/Margono/_old/margono_primary_forest_Papua_reclassified.tif')

writeRaster(rasterSumatra,'Shapefiles/Margono/margono_primary_forest_Sumatra_reclassified.tif')
writeRaster(rasterSumatra,'Shapefiles/Margono/margono_primary_forest_Kalimantan_reclassified.tif')
writeRaster(rasterSumatra,'Shapefiles/Margono/margono_primary_forest_Papua_reclassified.tif')

rasterSulawesi <- raster('Shapefiles/Margono/margono_primary_forest_Sulawesi_reclassified.tif')
rasterJava <- raster('Shapefiles/Margono/margono_primary_forest_Java_reclassified.tif')
rasterBali <- raster('Shapefiles/Margono/margono_primary_forest_Bali_Nusa_Tenggara_reclassified.tif')
rasterMaluku <- raster('Shapefiles/Margono/margono_primary_forest_Maluku_reclassified.tif')

aoi <- st_read("Shapefiles/Admin_areas/islands/islands.shp")
e <- extent(aoi)
template <- raster(e)
IDNCRS <- "+proj=cea +lon_0=115.0 +lat_ts=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"
proj4string(template) <- IDNCRS
writeRaster(template, file='Shapefiles/Margono/margonoAll.tif', format="GTiff")

islandRasters <- c("rasterSumatra","rasterKalimantan","rasterPapua","rasterSulawesi","rasterJava","rasterBali","rasterMaluku")

margonoAll <- merge(rasterSumatra,rasterKalimantan,rasterPapua,rasterSulawesi,rasterJava,rasterBali,rasterMaluku)
writeRaster(margonoAll,"Shapefiles/Margono/margono_primary_forest_all_reclassified.tif")

islandRasters <- c(
        'Shapefiles/Margono/margono_primary_forest_Sumatra_reclassified.tif',
        'Shapefiles/Margono/margono_primary_forest_Kalimantan_reclassified.tif',
        'Shapefiles/Margono/margono_primary_forest_Papua_reclassified.tif',
        'Shapefiles/Margono/margono_primary_forest_Sulawesi_reclassified.tif',
        'Shapefiles/Margono/margono_primary_forest_Java_reclassified.tif',
        'Shapefiles/Margono/margono_primary_forest_Bali_Nusa_Tenggara_reclassified.tif',
        'Shapefiles/Margono/margono_primary_forest_Maluku_reclassified.tif')

mosaic_rasters(gdalfile=islandRasters,dst_dataset='Shapefiles/Margono/margonoAll.tif')

writeRaster(margonoAll,"Shapefiles/Margono/margono_primary_forest_all_reclassified.tif")

margonoAll <- raster('Shapefiles/Margono/margonoAll.tif')
plot(margonoAll)                     
