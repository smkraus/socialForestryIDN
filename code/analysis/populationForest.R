rm(list = ls())

# List all packages needed for session"foreign",
neededPackages = c("haven","dplyr","sf","raster","exactextractr","stars","readr","fasterize") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

# population <- raster("Shapefiles/Population/population_idn_2018-10-01_geotiff_FB/population_idn_2018-10-01.tif")
populationTable <- read.csv("Shapefiles/Population/population_idn_2018-10-01.csv")

population <- st_as_sf(populationTable,coords=c("longitude","latitude"),crs = 4326)

# rasterTemplate = raster(extent(population), resolution = 0.00027777777777778)
# populationRaster <- fasterize::fasterize(population,rasterTemplate)
# st_write(population,"Shapefiles/Population/population.geojson")

KH <- st_read("ShapeFiles/KawasanHutan/Greenorb_Blog/final/KH-INDON-Final.json")
# IDN <- readRDS("Shapefiles/Admin_areas/gadm36_IDN_0_sf.rds")
# IDN$population <- exact_extract(population, IDN, 'sum')


KH <- KH[!st_is_empty(KH),,drop=FALSE]

KHPop <- st_join(KH,population,left = TRUE)

KHProj <- st_transform(KH,23839)
KHBuffer <- st_buffer(KHProj,1000)

KHBuffer <- st_transform(KHBuffer,4326)
KHBufferPop <- st_join(KHBuffer,population,left = TRUE)


KH$population <- exact_extract(population, KH, 'sum')
KHBuffer$population <- exact_extract(population, KH, 'sum')

st_geometry(KHPop) <- NULL
st_geometry(KHBufferPop) <- NULL


KHPop2015 <- KHPop %>% filter(!is.na(population_2015)) %>%
  summarize(popTotal = sum(population_2015))

KHPop2020 <- KHPop %>% filter(!is.na(population_2020)) %>%
  summarize(popTotal = sum(population_2020))

KHBuffPop2015 <- KHBufferPop %>% filter(!is.na(population_2015)) %>%
  summarize(popTotal = sum(population_2015))

KHBuffPop2020 <- KHBufferPop %>% filter(!is.na(population_2020)) %>%
  summarize(popTotal = sum(population_2020))

