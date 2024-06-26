# R script for "carob"

## ISSUES
# ....


carob_script <- function(path) {

"Description:
TAMASA Agronomy Panel Survey in Nigeria (2016) (2016)
"

	uri <- "hdl:11529/10548307"
	dataset_id <- carobiner::simple_uri(uri)
	group <- "crop_cuts"
	## dataset level data 
	dset <- data.frame(
		dataset_id = dataset_id,
		group=group,
		project="TAMASA",
		uri=uri,
		data_citation="Masuki, Kenneth; Chamberlin, Jordan, 2019, Tamasa APS Tanzania 2016, https://hdl.handle.net/11529/10548307, CIMMYT Research Data & Software Repository Network, V1, UNF:6:ROFhHRpFl3nj0rn+rxjaIA== [fileUNF]",
		## if there is a paper, include the paper's doi here
		## also add a RIS file in references folder (with matching doi)
		publication= NA,
		data_institutions = "CIMMYT",
		data_type="survey",
		carob_contributor="Shumirai Manzvera and Robert Hijmans" 
	)

## download and read data 
	ff  <- carobiner::get_data(uri, path, group)
	js <- carobiner::get_metadata(dataset_id, path, group, major=1, minor=1)
	dset$license <- carobiner::get_license(js)

	getdf <- function(r) {

		# remove "average" etc.
		r <- r[!is.na(r$Country), ]
		r <- r[r$Country == "Tanzania", ]

		d <- data.frame(country=r$Country, adm1=r$Region,
			adm2=r$District, adm3=r$Ward, location=r$Village,  
			elevation=r$Altitude, longitude= r$Longitude, latitude=r$Latitude)

		if (!is.null(r$Hamlet)) {
			d$site=r$Hamlet
			d$site <- gsub("\\.", " ", d$site)
			nc <- 6
		} else {
			nc <- 5
		}

		d$adm2 <- gsub("_", " ", d$adm2)
		d$adm3 <- gsub("\\.", " ", d$adm3)
		d$adm3 <- gsub("Kirongosamanga", "Kirongo Samanga", d$adm3)
		for (i in 2:5) {
			d[,i] <- gsub("n/a", NA, d[,i])
			d[,i] <- carobiner::fix_name(d[,i], "title")
		}
		
		if (!is.null(r$HHID)) {
			d$trial_id <- r$HHID
		} else {
			# FarmID and Farm_ID
			d$trial_id <- r$Farm
		}
		
		d$date <- r$`sampling Date`
		
		d$yield <- r$`Grain yield (kg/ha`  # catches both variants
		if (!is.null(r$`Plant stands`)) d$plant_density <- 400 * r$`Plant stands` 
		d$soil_pH <- r$pH 

###
# to do: check units!
###
		d$soil_Al <- r[["Al"]] # avoid partial matching
		d$soil_N <- r[["N"]]
		d$soil_Na <- r$Na
		d$soil_Fe <- r$Fe
		d$soil_K <- r$K
		d$soil_S <- r[["S"]]
		d$soil_B <- r[["B"]]
		d$soil_C <- r$C
		d$soil_Ca <- r$Ca
		d$soil_Mg <- r$Mg
		d$soil_Mn <- r$Mn
		d$soil_Zn <- r$Zn
		if (!is.null(r$Depth)) {
			p <- gsub("–", "-", r$Depth)
			p <- strsplit(p, "-")
			p <- do.call(rbind, p)
			d$soil_sample_top <- as.numeric(p[,1])
			d$soil_sample_bottom <- as.numeric(p[,2])
		} 
		if (!is.null(d$yield)) d <- d[!is.na(d$yield), ]
		d <- d[order(d$trial_id), ]
		rp <- unlist(lapply(split(d$trial_id, d$trial_id), seq_along))
		d
	}	

	f1 <- ff[basename(ff) == "TAMASA_TZ_APS_CC_2016.xlsx"]
	r1 <- carobiner::read.excel(f1, "Data")
	hhid <- r1$HHID
	r1$HHID <- r1$FarmID
	r1$FarmID <- r1$hhid
	d1 <- getdf(r1)
	d1 <- d1[!is.na(d1$yield), ]
	
#	unlist(lapply(split(d1$HHID, d1$HHID), seq_along))
	
	f2 <- ff[basename(ff) == "TAMASA_TZ_APS_Soil_2016.xlsx"]
	r2 <- carobiner::read.excel(f2, "Data")
	d2 <- getdf(r2)
	d2a <- d2[d2$soil_sample_top == 0, ]
	d2a <- d2a[, c('trial_id', 'soil_pH', 'soil_Al', 'soil_N', 'soil_Na', 'soil_Fe', 'soil_K', 'soil_S', 'soil_B', 'soil_C', 'soil_Ca', 'soil_Mg', 'soil_Mn', 'soil_Zn', 'soil_sample_top', 'soil_sample_bottom')]
	d2a <- aggregate(d2a[,-1], d2a[, 1, drop=FALSE], mean, na.rm=TRUE)
	d12 <- merge(d1, d2a, by="trial_id", all.x=TRUE)
		
	d12$date <- "2016"

	
	f3 <- ff[basename(ff) == "TZ_TAMASA_BYS_Yield_2015_22June17.xlsx"]
	# use n_max to avoid reading a summary row that will be descarded but would 
	# mess up the date field
	r3 <- carobiner::read.excel(f3, "Yield Data", n_max=427)
	d3 <- getdf(r3)
	d3$date <- as.character(as.Date(d3$date))
	
	f4 <- ff[basename(ff) == "TZ_TAMASA_BYS_Yield_2015_22June17.xlsx"]
	r4 <- carobiner::read.excel(f4, "Soil data")
	d4 <- getdf(r4)
	d4a <- d4[d4$soil_sample_top == 0, ]
	d4a <- d4[, c('trial_id', 'soil_pH', 'soil_Al', 'soil_N', 'soil_Na', 'soil_Fe', 'soil_K', 'soil_S', 'soil_B', 'soil_C', 'soil_Ca', 'soil_Mg', 'soil_Mn', 'soil_Zn', 'soil_sample_top', 'soil_sample_bottom')]
	d4a <- aggregate(d4a[,-1], d4a[, 1, drop=FALSE], mean, na.rm=TRUE)
	d34 <- merge(d3, d4a, by="trial_id", all.x=TRUE)
	
	d <- carobiner::bindr(d12, d34)
	
	d$dataset_id <- dataset_id
	d$on_farm <- FALSE
	d$is_survey <- TRUE
	d$irrigated <- FALSE
	d$yield_part <- "grain" 
	d$crop <- "maize"
	d$planting_date <- as.character(NA)
	
	carobiner::write_files(dset, d, path=path)

## also write all soil data to the soil_samples group
## including deeper layer, and records not matched.

	soil <- carobiner::bindr(d2, d4)
	soil$dataset_id <- dataset_id
	dset$group <- "soil_samples"	
	carobiner::write_files(dset, soil, path=path)

}

