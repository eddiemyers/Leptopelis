
#Written by E. A. Myers but was modified from (and largely based on!!) scripts written by Juan Luis Parra 
#(for 'Curso de Modelado de Nichos Ecologicos y Distribuciones Geograficas', Marzo 2017)
#August 2020
#If used please cite the following papers:
#Bell, R. C., et al. 2017.  https://doi.org/10.1111/mec.14260
#and
#Jaynes, K., E. A. Myers, et al. in prep.

library(sp)
library(maptools)
library(rgdal)
library(raster)

##################################################################
#Localities for all frogs from subsaharan Africa
anuransAfrica <- read.csv('AfricaAnuraRecords2014.csv', header=T)

##################################################################
#map Africa
africa <- readOGR('Africa_SHP/Africa.shp')
ext=extent(c(-18, 52, -35, 15))

#Species occurrences, only add these to illustrate that your localities load correctly, etc.
#spp_occs <- read.csv('rufus_localities.csv', header=T)
#transform to spatial table
#coordinates(spp_occs) <- spp_occs[,3:2]

#Plot to verify
plot(africa)
#only add anuransAfrica if you want to see a ton of points, but illustrates it worked
points(anuransAfrica[,c(8,7)], pch=20, col='gray')
#plot(spp_occs, add=T)

##################################################################
#convert table into a spatial object (similar to a vector file)
anuransAfrica_sp <- anuransAfrica
coordinates(anuransAfrica_sp) <- c('decimallongitude','decimallatitude')

##################################################################
# There are multiple ways to make a sampling effort file based on these data
# could be by number of records or by number of sampling years

####load bioclim layer to use as a raster template
raster("~/Documents/R_scripts/map_layers/WorldClim_data/current_bio_2-5m_bil/bio1.bil")->bios
bios <- crop(bios, ext)
###
###This will ensure that Madagascar isn't sampled when taking background points
chull(coordinates(anuransAfrica_sp))->hull
coords <- coordinates(anuransAfrica_sp)[c(hull, hull[1]), ]
lines(coords, col="red")
sp_poly <- SpatialPolygons(list(Polygons(list(Polygon(coords)), ID=1)))
sp_poly_df <- SpatialPolygonsDataFrame(sp_poly, data=data.frame(ID=1))
bios2 <- crop(bios, extent(sp_poly_df))
chull_Africa <- raster::mask(bios2, sp_poly_df)
plot(chull_Africa)

##################################################################
####By sampling effort per years

#Dissagregate study area to ~1 km resolution (at equator)
chull_Africa.disaggregate <- disaggregate(chull_Africa, fact=5)
#Rasterize spatial data frame to a resolution of ~1 km
samp_year <- rasterize(anuransAfrica_sp, chull_Africa.disaggregate,fun=function(x,...) length(unique(x)), field='year') 

#leave values only within the study region (e.g., remove N. African samps if included originally)
samp_year <- mask(samp_year,chull_Africa.disaggregate)

#aggregate raster to 10km resolution and sum all sampled years across this aggregation
samp_year.aggregate <- aggregate(samp_year, fact=11.25, fun=sum)

#disaggregate raster, keeping the same summed sample years in all disag. cells
#this final file should have a resolution of 1km (or 0.008333333, 0.008333333  (x, y))
samp_year_Final <- disaggregate(samp_year.aggregate, fact=11.25)

#add 0.01 to all cells so that when sampling by probability, these aren't 0's
samp_year_Final <- samp_year_Final + 0.01

#save as an ascii file
#writeRaster(samp_year_Final, file='test_samp_year_1_mx.asc', format='ascii')
##################################################################

samp_cell <- data.frame(cell = 1:ncell(samp_year_Final), value=samp_year_Final[])
samp_cell <- na.omit(samp_cell)
samp_cell = sample(samp_cell$cell,10000, prob=samp_cell$value, replace=FALSE)
bg_pts_year = xyFromCell(samp_year_Final, samp_cell)

#verify
plot(bios)
points(bg_pts_year, cex=0.5, pch=20, col='blue')
#save background sampling points
write.csv(bg_pts_year, file ="bg_pts_year.csv", row.names = F)



