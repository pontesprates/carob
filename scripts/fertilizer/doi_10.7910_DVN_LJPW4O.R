# R script for "carob"

## ISSUES
# ....


carob_script <- function(path) {

"
	Description:
	Response of maize to N and P in two trials in Uganda
"

	uri <- "doi:10.7910/DVN/LJPW4O"
	dataset_id <- carobiner::simple_uri(uri)
	group <- "fertilizer"
	## dataset level data 
	dset <- data.frame(
	   dataset_id = dataset_id,
	   data_citation = "Sommer, Rolf; Kihara, Job; Kinyua, Michael, 2019, Response of maize to N and P in two trials in Uganda, https://doi.org/10.7910/DVN/LJPW4O, Harvard Dataverse",
	   group=group,
	   uri=uri,
	   publication=NA,
	   carob_contributor="Eduardo Garcia Bendito",
	   data_type = "experiment",
		data_institutions=NA,
		project=NA
    
	)

## download and read data 

	ff  <- carobiner::get_data(uri, path, group)
	js <- carobiner::get_metadata(dataset_id, path, group, major=1, minor=5) 
	dset$license <- carobiner::get_license(js)


	f <- ff[basename(ff) == "9a Yield data.xlsx"]

	d <- carobiner::read.excel(f)
	d$country <- "Uganda"
	d$adm1 <- "Wakiso"
	d$adm2 <- "Jinja"
	d$adm3 <- ifelse(d$Site == "Kawanda", "Nabweru", "Busukuma")
	d$trial_id <- paste0(dataset_id, '-', d$Site)
	d$latitude <- ifelse(d$Site == "Kawanda", 0.4172778, 0.5256090)
	d$longitude <- ifelse(d$Site == "Kawanda", 32.5355326, 32.6136960)
	d$planting_date <- "2013-08-10"
	d$harvest_date <- "2014"
	d$on_farm <- FALSE
	d$is_survey <- TRUE	
	d$crop <- "maize"
	d$yield_part <- "grain"
	d$variety <- "Longe 10H"
	d$variety_code <- "SC627"
	
	# Merge with measured biomass ("2a Dry matter measurements.xlsx")
	biomass <- carobiner::read.excel(ff[basename(ff) == "2a Dry matter measurements.xlsx"])
	biomass$Season <- ifelse(biomass$`Days after planting (dap)` == 30, 1, 2)
	biomass$season <- "rainy"
	biomass$observation_date <- as.Date("2013-08-10", format='%Y-%m-%d')+biomass$`Days after planting (dap)`
	biomass <- biomass[order(biomass[,"Site"], biomass[,"Season"], biomass[,"Block"], biomass[,"Treatment"]), ]
	biomass1 <- aggregate(biomass[, "Dry weight with roots (g)", drop=FALSE], 
						  biomass[, c("Site", "Season", "season", "Block", "Treatment")], FUN=mean)
	d1 <- merge(d, biomass1, by = intersect(names(d), names(biomass1)), all.x = TRUE)
	# 5 plants sampled; 53.333 plants/ha
	d1$biomass_total <- ((d1$`Dry weight with roots (g)` * 10.666))/1000
	d1$Plot <- biomass$Plot
	
	# Adding Treatment information
	d1$fertilizer_type <- "urea"
	d1$N_fertilizer <- ifelse(d$Treatment %in% c(8,7,6,5,4), 200,
	                          ifelse(d$Treatment %in% c(3), 60, 0))
#	d1$N_splits <- paste(d1$N_fertilizer*0.3,d1$N_fertilizer*0.3,d1$N_fertilizer*0.4, sep = " | ")
	d1$N_splits <- NA
	d1$N_splits[d1$N_fertilizer > 0] <- 3L

	d1$P_fertilizer <- ifelse(d$Treatment %in% c(8,7,3,2), 90,
						 ifelse(d$Treatment %in% c(6), 50,
						   ifelse(d$Treatment %in% c(5), 20, 0)))
	d1$K_fertilizer <- ifelse(d$Treatment == 1, 0, 75)
	d1$Zn_fertilizer <- ifelse(d$Treatment == 1, 0, 75)
	
	###########
	# Missing information on amount of manure applied.
	# Have sent an email to Job Kihara to find out about the manure applied (2021/09/17)
	###########
	# Merge with Manure applied ("1a Cattle manure lab analysis.xlsx")
	OM <- carobiner::read.excel(ff[basename(ff) == "1a Cattle manure lab analysis.xlsx"], skip = 5)
	d1$OM_used <- d1$Treatment == 8
	d1$OM_type <- ifelse(d1$Treatment == 8, "manure", NA)
	d1$OM_applied <- ifelse(d1$Treatment == 8, 5000, 0)
	d1$OM_N <- d1$OM_applied*(0.1796/100)*(0.755/100) # OM$K (%)
	d1$OM_P <- d1$OM_applied*(0.1796/100)*(200.67532467532467/1e+06) # OM$P (ppm)
	d1$OM_K <- d1$OM_applied*(0.1796/100)*(66.9072/1e+06) # OM$K (ppm)

	# Merge with Soil data ("8a Soil lab data.xlsx")
	soil <- carobiner::read.excel(ff[basename(ff) == "8a Soil lab data.xlsx"], skip = 12)
	soil$Block <- sub("^\\D*(\\d+).*$", "\\1",  soil$`Client's ref`)
	soil$Plot <- sub('.*(?=.{2}$)', '', soil$`Client's ref`, perl=T)
	soil1 <- soil[,c(1,4:17)]
	# Consider only the first 30 cm
	soil1 <- soil1[soil1$`Depth (CM)` == "0-15" | soil1$`Depth (CM)` == "15-30", ]
	soil1$`P (ppm)`[soil1$`P (ppm)` == "trace"] = 0.01
	soil1$`P (ppm)` <- as.numeric(soil1$`P (ppm)`)
	soil1$Block <- as.numeric(soil1$Block)
	soil1$Plot <- as.numeric(soil1$Plot)
	soil1$`N (%)` <- soil1$`N (%)`*10
	soil1$`P (ppm)` <- soil1$`P (ppm)`/1000
	soil1$`K (ppm)` <- soil1$`K (ppm)`/1000
	soil2 <- aggregate(soil1[, c(3,5,6,9,10,11)], list(Site = soil1$Site, Block = soil1$Block, Plot = soil1$Plot), mean, na.rm = TRUE)
	soil2 <- soil2[order(soil2[,"Site"], soil2[,"Block"], soil2[,"Plot"]), ]
	d2 <- merge(d1, soil2, by = intersect(names(d1), names(soil2)), all.x = TRUE)
	d2$yield <- d2$`Grain yield (kg/plot -5.625m2)` * (10000/5.625)
	d2$residue_yield <- d2$`Stover yield (kg/plot - 5.625m2)` * (10000/5.625)
	d2$irrigated <- TRUE
	d2$row_spacing <- 75
	d2$plant_spacing <- 25
	
	# process file(s)
	d <- carobiner::change_names(d2,
	     c("Site", "pH", "N (%)", "K (ppm)", "P (ppm)", "Sand (%)", "Clay (%)"),
	     c("site", "soil_pH", "soil_N", "soil_K", "soil_P_total", "soil_sand", "soil_clay"))
		 	 
	d <- d[,c("country", "adm1", "adm2", "adm3", "latitude", "longitude", "site", "planting_date", "harvest_date", "season", "on_farm", "is_survey", "crop", "variety", "variety_code", "biomass_total", "yield", "residue_yield", "fertilizer_type", "N_fertilizer", "N_splits", "P_fertilizer", "K_fertilizer", "Zn_fertilizer", "OM_used", "OM_type", "OM_applied", "OM_N", "OM_P", "OM_K", "soil_pH", "soil_N", "soil_K", "soil_P_total", "soil_sand", "soil_clay", "irrigated", "row_spacing","plant_spacing")]

	id <- ifelse(d$site == "Kawanda", seq(1,sum(d$site == "Kawanda")), 
										seq(1,sum(d$site == "Namulonge")))
	
	d$trial_id <- paste0(d$trial_id, "-", id)
	d$dataset_id <- dataset_id
	d$yield_part <- "grain"
# all scripts must end like this
	carobiner::write_files(dset, d, path=path)

}
