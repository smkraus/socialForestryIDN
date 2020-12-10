rm(list = ls())

# List all packages needed for session"foreign",
neededPackages = c("haven","dplyr","sf","sp","rgeos","raster","lwgeom") 

allPackages    = c(neededPackages %in% installed.packages()[ , "Package"]) 

# Install packages (if not already installed) 
if(!all(allPackages)) {
  missingIDX = which(allPackages == FALSE)
  needed     = neededPackages[missingIDX]
  lapply(needed, install.packages)
}

# Load all defined packages
lapply(neededPackages, library, character.only = TRUE)


# customCRS <- "+proj=cea +lon_0=115.0 +lat_ts=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"

# Protection forest
# KH <- st_read("Shapefiles/KawasanHutan/Greenorb_Blog/final/KH-INDON-Final.shp", stringsAsFactors = FALSE)
# KH_sp <- as(KH, 'Spatial') %>% spTransform(CRS=CRS("+init=epsg:23839")) %>% gBuffer(byid=TRUE, width=0)

KH <- st_read("Shapefiles/KawasanHutan/KLHK_Server/new/KHAllHS.geojson", stringsAsFactors = FALSE) %>%
  st_zm(drop = TRUE, what = "ZM")
KH_sp <- as(KH, 'Spatial') %>% spTransform(CRS=CRS("+init=epsg:23839")) %>% gBuffer(byid=TRUE, width=0)


# HL <- KH %>% filter(Fungsi == "HL")
# HL_sp <- as(HL, 'Spatial') %>% spTransform(CRS(customCRS)) %>% gBuffer(byid=TRUE, width=0)


# Granted areas old
HD <- st_read("Shapefiles/SFPShapes/raw/HPHD.shp", stringsAsFactors = FALSE)
HKm <- st_read("Shapefiles/SFPShapes/raw/IUPHKM.shp", stringsAsFactors = FALSE)
HTR <- st_read("Shapefiles/SFPShapes/raw/IUPHHKHTR.json", stringsAsFactors = FALSE)
# HTR has broken polygons
#   GDAL Error 6: Geometry type of `3D Multi Polygon' not supported in shapefiles.  Type can be overridden with a layer creation option of SHPT=POINT/ARC/POLYGON/MULTIPOINT/POINTZ/ARCZ/POLYGONZ/MULTIPOINTZ/MULTIPATCH.
# HDArea <- HD %>% dplyr::select(hd_idn_sk_hp,luas_pl)
# st_geometry(HDArea) <- NULL
# haven::write_dta(HDArea,"Shapefiles/SFPShapes/HDArea.dta")
# 
# HKmArea <- HKm %>% dplyr::select(objectd,luas_pl)
# st_geometry(HKmArea) <- NULL
# haven::write_dta(HKmArea,"Shapefiles/SFPShapes/HKmArea.dta")
# 
# HTRArea <- HTR %>% dplyr::select(objectd,luas_iuphhkhtr)
# st_geometry(HTRArea) <- NULL
# haven::write_dta(HTRArea,"Shapefiles/SFPShapes/HTRArea.dta")

HD$sfpType <- "HD"
HKm$sfpType <- "HKm"
HTR$sfpType <- "HTR"

HD <- HD %>% dplyr::select(landTitle = n_sk_hp,sfpType,geometry) %>% dplyr::filter(!st_is_empty(geometry))
HKm <- HKm %>% dplyr::select(landTitle = n_sk_ph,sfpType,geometry) %>% dplyr::filter(!st_is_empty(geometry))
HTR <- HTR %>% dplyr::select(landTitle = no_sk_iuphhkhtr,sfpType,geometry) %>% dplyr::filter(!st_is_empty(geometry))
sfp <- rbind(HD,HKm)
sfp <- sfp %>% dplyr::filter(!st_is_empty(geometry))

sfp <- sfp %>% 
  mutate(idArea = paste0("sfp",rownames(.))) %>% 
  dplyr::select(idArea, everything())
sfp <- sfp %>% 
  mutate(id = paste0("sfp",rownames(.),"All")) %>% 
  dplyr::select(id, everything())
sfp$forestFunction <- "all"
sfp$mapSource <- "SINAV"
sfp$criterion <- NA
sfp$recentlyTitled <- NA
sfp$Proposed <- NA
sfp$dataset <- "sfp"
# st_write(HL,"Shapefiles/ProtectionForest/Greenorb_Blog/final/HL.shp")

# sfp_sp <- as(sfp, 'Spatial') %>% spTransform(CRS(customCRS)) %>% gBuffer(byid=TRUE, width=0)
# # clip <- gIntersection(HL_sp, HD_sp, byid = TRUE, drop_lower_td=TRUE)
# sfpinHL <- raster::intersect(sfp_sp,HL_sp)
# sfpinHL_sf <- st_as_sf(sfpinHL)
# sfpinHL_sf$forestFunction <- "HL"
# sfpinHL_sf <- sfpinHL_sf %>% dplyr::select(-id,-Fungsi,-Province)     %>%
# mutate(id = paste0("sfp",rownames(.),"HL"))  %>% 
# dplyr::select(id, everything())

# st_write(sfpinHL_sf,"Shapefiles/SFPShapes/sfpinHL.shp")
# st_write(sfp,"Shapefiles/SFPShapes/sfp.shp")

# Granted areas new

# Download on 14/09/2020

HD <- st_read("Shapefiles/KLHK_shapes/raw/Hutan_Desa_new.json", stringsAsFactors = FALSE)
HDAreaShares <- HD %>% dplyr::select(OBJECTID,LUAS_HL,LUAS_HP,LUAS_HPT,LUAS_HPK,LUAS_HPHD)
HDAreaShares$sfpType <- "HD"
st_geometry(HDAreaShares) <- NULL


HA <- st_read("Shapefiles/KLHK_shapes/raw/Hutan_Adat_new.json", stringsAsFactors = FALSE)

HKm1 <- st_read("Shapefiles/KLHK_shapes/raw/Hutan_Kemasyarakatan_new1.json", stringsAsFactors = FALSE)
HKm2 <- st_read("Shapefiles/KLHK_shapes/raw/Hutan_Kemasyarakatan_new2.json", stringsAsFactors = FALSE)

HKm <- rbind(HKm1,HKm2)

HTR1 <- st_read("Shapefiles/KLHK_shapes/raw/Hutan_Tanaman_Rakyat_new1.json", stringsAsFactors = FALSE)
HTR2 <- st_read("Shapefiles/KLHK_shapes/raw/Hutan_Tanaman_Rakyat_new2.json", stringsAsFactors = FALSE)
HTR3 <- st_read("Shapefiles/KLHK_shapes/raw/Hutan_Tanaman_Rakyat_new3.json", stringsAsFactors = FALSE)

HTR <- rbind(HTR1,HTR2,HTR3)

# HDArea <- HD %>% dplyr::select(OBJECTID,LUAS_HPHD)
# st_geometry(HDArea) <- NULL
# haven::write_dta(HDArea,"Shapefiles/KLHK_shapes/HDArea.dta")

HAArea <- HA
HAArea$areaSize <- st_area(HAArea)
HAArea$areaSize <- units::set_units(HAArea$areaSize, value = ha)

HAArea <- HAArea %>% dplyr::select(LUAS,Shape_Area,areaSize)
st_geometry(HAArea) <- NULL
haven::write_dta(HAArea,"Shapefiles/KLHK_shapes/HAArea.dta")

HD$sfpType <- "HD"
HKm$sfpType <- "HKm"
HTR$sfpType <- "HTR"
HA$sfpType <- "HA"

HD <- HD %>% dplyr::select(OBJECTID,landTitle = NO_SK_HPHD,sfpType,Luas = LUAS_POLI,Shape_Area = SHAPE_Area,geometry) %>% dplyr::filter(!st_is_empty(geometry))
HKm <- HKm %>% dplyr::select(OBJECTID,landTitle = NO_IUPHKM,sfpType,Luas = LUAS_POLI,Shape_Area = SHAPE_Area,geometry) %>% dplyr::filter(!st_is_empty(geometry))
HTR <- HTR %>% dplyr::select(OBJECTID,landTitle = NO_IUPHHK_HTR,sfpType,Luas = LUAS_POLI,Shape_Area = SHAPE_Area,geometry) %>% dplyr::filter(!st_is_empty(geometry))
HA <- HA %>% dplyr::select(OBJECTID,landTitle = SK_MENLHK,sfpType,Luas = LUAS,Shape_Area = Shape_Area,geometry) %>% dplyr::filter(!st_is_empty(geometry))

# st_write(HTR,"Shapefiles/SFPShapes/raw/IUPHHKHTR.shp")

sfpNew <- rbind(HD,HKm,HTR)

sfpNew <- sfpNew %>% st_transform(23839)

sfpNew <- sfpNew %>% 
  mutate(idArea = paste0("sfpNew",rownames(.))) %>% 
  dplyr::select(idArea, everything())
sfpNew <- sfpNew %>% 
  mutate(id = paste0("sfpNew",rownames(.),"All")) %>% 
  dplyr::select(id, everything())
sfpNew$forestFunction <- "all"
sfpNew$mapSource <- "KLHK"
sfpNew$recentlyTitled <- NA
sfpNew$criterion <- NA
sfpNew$Proposed <- NA
sfpNew$dataset <- "sfpNew"

HDLuas <- inner_join(sfpNew,HDAreaShares,by=c("OBJECTID","sfpType"))
st_geometry(HDLuas) <- NULL
HDLuas <- HDLuas %>% select(id,LUAS_HL,LUAS_HP,LUAS_HPT,LUAS_HPK,LUAS_HPHD)
haven::write_dta(HDLuas,"Shapefiles/KLHK_shapes/raw/Hutan_Desa_new_Luas_ID.dta")


sfpNew <- sfpNew %>% dplyr::select(-OBJECTID)

sfpNewArea <- sfpNew
sfpNewArea$areaSize <- st_area(sfpNewArea)
sfpNewArea$areaSize <- units::set_units(sfpNewArea$areaSize, value = ha)
st_geometry(sfpNewArea) <- NULL
haven::write_dta(sfpNewArea,"Shapefiles/KLHK_shapes/sfpNewArea.dta")

sfpNew <- sfpNew %>% dplyr::select(-Luas,-Shape_Area)

# st_write(HL,"Shapefiles/ProtectionForest/Greenorb_Blog/final/HL.shp")

sfpNew_sp <- as(sfpNew, 'Spatial') %>% spTransform(CRS=CRS("+init=epsg:23839")) %>% gBuffer(byid=TRUE, width=0)


# # clip <- gIntersection(KH_sp, HD_sp, byid = TRUE, drop_lower_td=TRUE)
# 
sfpNewKH <- raster::intersect(sfpNew_sp,KH_sp)
sfpNewKH_sf <- st_as_sf(sfpNewKH)
sfpNewKH_sf <- sfpNewKH_sf %>% dplyr::select(-id,-forestFunction,-OBJECTID) %>%
  mutate(id = paste0("sfpNew",rownames(.),"HL"))  %>%
  dplyr::select(id, everything()) %>%
  rename(forestFunction = FUNGSIKWS)

sfpNew <- sfpNew %>% dplyr::select(everything())
sfpNewKH_sf <- sfpNewKH_sf %>% dplyr::select(everything())

# Planned areas
UsulanHD <- st_read("Shapefiles/SFPShapes/raw/Usulan_HD.json",stringsAsFactors = FALSE) %>% dplyr::select(geometry)
UsulanHKm <- st_read("Shapefiles/SFPShapes/raw/Usulan_HKm.json",stringsAsFactors = FALSE) %>% dplyr::select(geometry)
UsulanHTR <- st_read("Shapefiles/SFPShapes/raw/Usulan_HTR.json",stringsAsFactors = FALSE) %>% dplyr::select(geometry)

UsulanHD$sfpType <- "HD"
UsulanHKm$sfpType <- "HKm"
UsulanHTR$sfpType <- "HTR"

UsulanHD$landTitle <- NA
UsulanHKm$landTitle <- NA
UsulanHTR$landTitle <- NA

usulan <- rbind(UsulanHD,UsulanHKm,UsulanHTR)

usulan <- sf::st_transform(usulan, 23839)

usulan$forestFunction <- "all"
usulan$criterion <- NA
usulan$mapSource <- "SINAV"
usulan$Proposed <- TRUE
usulan$dataset <- "Usulan"

usulan <- usulan %>% 
  mutate(idArea = paste0("usulan",rownames(.))) %>% 
  dplyr::select(idArea, everything())
usulan <- usulan %>% 
  mutate(id = paste0("usulan",rownames(.),"All")) %>% 
  dplyr::select(id, everything())

# intersects <- st_intersects(usulan$geometry, sfpNew$geometry) %>% 
#   lapply(FUN = function(x) data.frame(ind = length(x))) %>% 
#   bind_rows()

overlaps <- st_overlaps(usulan$geometry, sfpNew$geometry) %>% 
  lapply(FUN = function(x) data.frame(ind = length(x))) %>% 
  bind_rows()

# usulanNew <- dplyr::mutate(usulan, indicatorIntersects = intersects$ind)
usulan <- dplyr::mutate(usulan, indicatorOverlaps = overlaps$ind)
usulan <- dplyr::mutate(usulan, recentlyTitled = ifelse(usulan$indicatorOverlaps != 0,TRUE,FALSE)) %>% dplyr::select(-indicatorOverlaps)

# st_write(usulan,"Shapefiles/SFPShapes/usulan.shp")

# usulan_sp <- as(usulan, 'Spatial') %>% spTransform(CRS(customCRS)) %>% gBuffer(byid=TRUE, width=0)
# 
# # clip <- gIntersection(HL_sp, HD_sp, byid = TRUE, drop_lower_td=TRUE)
# 
# usulaninHL <- raster::intersect(usulan_sp,HL_sp)
# usulaninHL_sf <- st_as_sf(usulaninHL)
# usulaninHL_sf$forestFunction <- "HL"
# usulaninHL_sf <- usulaninHL_sf %>% dplyr::select(-id,-Fungsi,-Province) %>%
#   mutate(id = paste0("usulan",rownames(.),"HL")) %>% 
#   dplyr::select(id, everything())
# # st_write(usulaninHL_sf,"Shapefiles/SFPShapes/usulaninHL.shp")

# PIAPS control group
PIAPS3 <- st_read("Shapefiles/SFPShapes/raw/PlannedAreaSFP_v3/PIAPS-Revisi3.shp") %>% dplyr::select(forestFunction = fungsi,criterion=kriteri,geometry)
PIAPS3$sfpType <- NA
PIAPS3$landTitle <- NA
PIAPS3$idArea <- NA
PIAPS3$mapSource <- "SINAV"
PIAPS3$Proposed <- NA
PIAPS3$dataset <- "PIAPS"

PIAPS3 <- PIAPS3 %>% st_transform(23839)

PIAPS3 <- PIAPS3 %>% 
  mutate(id = paste0("PIAPS3",rownames(.),"All")) %>% 
  dplyr::select(id, everything())

overlaps <- st_overlaps(PIAPS3$geometry, sfpNew$geometry) %>% 
  lapply(FUN = function(x) data.frame(ind = length(x))) %>% 
  bind_rows()

PIAPS3 <- dplyr::mutate(PIAPS3, indicatorOverlaps = overlaps$ind)
PIAPS3 <- dplyr::mutate(PIAPS3, recentlyTitled = ifelse(PIAPS3$indicatorOverlaps != 0,TRUE,FALSE)) %>% dplyr::select(-indicatorOverlaps)

# PIAPS3_sp <- as(PIAPS3, 'Spatial') %>% spTransform(CRS(customCRS)) %>% gBuffer(byid=TRUE, width=0)
# PIAPS3inHL <- raster::intersect(PIAPS3_sp,HL_sp)
# PIAPS3inHL_sf <- st_as_sf(PIAPS3inHL)
# PIAPS3inHL_sf$forestFunction <- "HL"

# PIAPS3inHL_sf <- PIAPS3inHL_sf %>% dplyr::select(-id,-Fungsi,-Province) %>%
#   mutate(id = paste0("PIAPS3HL",rownames(.),"HL"))   %>% 
#   dplyr::select(id, everything())

# st_write(PIAPS3inHL_sf,"Shapefiles/SFPShapes/PIAPS3_spinHL.shp")

# # Putting everything together
# sfpCRS <- st_crs(sfp)
# sfs <- c(sfpNew,sfpNewinHL_sf,sfp,sfpinHL_sf,usulan,usulaninHL_sf,PIAPS3)
# 
# sfpNewinHL_sf <- st_transform(sfpNewinHL_sf,sfpCRS)
# sfpinHL_sf <- st_transform(sfpinHL_sf,sfpCRS)
# usulaninHL_sf <- st_transform(usulaninHL_sf,sfpCRS)

# sfpAll <- rbind(sfpNew,sfpNewinHL_sf,sfp,sfpinHL_sf,usulan,usulaninHL_sf,PIAPS3)

sfp <- sf::st_transform(sfp,23839)
sfpAll <- rbind(sfpNew,sfpNewKH_sf,sfp,usulan,PIAPS3)

sfpAll <- sf::st_transform(sfpAll,4326)
sfpAll$areaSize <- st_area(sfpAll)
sfpAll$areaSize <- units::set_units(sfpAll$areaSize, value = ha)
st_write(sfpAll,"Shapefiles/sfpAll.shp")
sfpAll <- sf::st_transform(sfpAll, 23839)
# sfpSubset <- sfpAll %>% dplyr::filter((dataset == "Usulan" | dataset == "sfpNew") & frstFnction == "all")
# sfpSubsetGEE <- sfpGSubset %>% dplyr::select(id,geometry)
# sf::st_write(sfpSubsetGEE,"Shapefiles/sfpSubsetGEE.shp")
# 

sfpAllGEE <- sfpAll %>% sf::st_transform(4326) %>% dplyr::select(id,geometry)
st_write(sfpAllGEE,"Shapefiles/sfpAllGEE.shp")

districts <- sf::st_read("Shapefiles/Admin_areas/idn_bnd_adm2_2015_bps_a.shp")
# province <- sf::st_read("Shapefiles/Admin_areas/idn_bnd_adm2_2015_bps_a.shp") %>% dplyr::select(-A2CODE)
# districts <- sf::st_read("Shapefiles/Admin_areas/district2000/district_2015_base2000.shp") %>% rename(A2CODE = d__2000)
districts <- st_transform(districts,23839)
districts <- sf::st_buffer(districts, dist = 0)

sfpAll <- sf::st_transform(sfpAll, 23839)
sfpAll <- sf::st_buffer(sfpAll, dist = 0)

sfpAllGeo <- sf::st_join(sfpAll,districts,largest = TRUE,left = TRUE)
# sfpAllGeo <- sf::st_join(sfpAllGeo,province,largest = TRUE,left = TRUE)


sf::st_geometry(sfpAllGeo) <- NULL
haven::write_dta(sfpAllGeo,"Shapefiles/sfpAllGeo.dta")
# sf::st_write(sfpAllGeo,"Shapefiles/sfpAllGeo.shp")

sfpAllDta <- sfpAll
st_geometry(sfpAllDta) <- NULL
haven::write_dta(sfpAllDta,"Shapefiles/sfpAll.dta")

sfpAreaDataId <- sfpAllDta %>% dplyr::select(id,dataset,areaSize)
haven::write_dta(sfpAreaDataId,"Shapefiles/sfpAreaDataId.dta")


sfpArea <- sfpAllDta %>% dplyr::select(-dataset)
haven::write_dta(sfpArea,"Shapefiles/sfpArea.dta")

