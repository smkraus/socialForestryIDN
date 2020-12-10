rm(list = ls())

# List all packages needed for session"foreign",
neededPackages = c("sf","raster","exactextractr") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)

sfpAllGEE <- st_read("Shapefiles/sfpAllGEE.shp")

# for (i in 2001:2019) {
#   link <- paste0("https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_annual/tifs/chirps-v2.0.",i,".tif.gz")
#   localFile <- paste0("Shapefiles/Precipitation/chirps-v2.0.",i,".tif.gz")
#   download.file(link,localFile)
# }

precipYearList = list()

for (i in 2001:2019) {
  fileName <- paste0("chirps-v2.0.",i,".tif")
  link <- paste0("Shapefiles/Precipitation/",fileName,"/",fileName)
  precipGlobal <- raster(link)
  precipIDN <- crop(precipGlobal,sfpAll)
  sfpPrecip <- sfpAll
  sfpPrecip$precMeanAnnual <- exact_extract(precipIDN,sfpPrecip,'mean')
  st_geometry(sfpPrecip) <- NULL
  sfpPrecip$year <- i  # maybe you want to keep track of which iteration produced it?
  precipYearList[[i]] <- sfpPrecip # add it to your list
}

sfpAllPrecip <- do.call(rbind, precipYearList)

haven::write_dta(sfpAllPrecip,"Panels/Controls/precipitationNew.dta")


