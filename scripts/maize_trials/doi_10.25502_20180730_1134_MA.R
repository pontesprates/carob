
carob_script <- function(path) {
"
This is an international study that contains data on yield and other Agronomic traits of maize including borer and striga attacks on maize in Africa.

The study was carried out by the International Institute of Tropical Agriculture between 1989 and 2015 in over thirty African countries.

This dataset contains output of the research for Republic of Benin.
"

	uri <- "doi:10.25502/20180730/1134/MA"
	dataset_id <- carobiner::simple_uri(uri)
	group <- "maize_trials"	
		
	## dataset level data 
	dset <- data.frame(
		dataset_id = dataset_id,
		data_citation = "Menkir, A. (2018). Grain Yield and Other Agronomic Traits of International Maize Trials – Republic of Benin, 1989 - 2015 [Data set]. International Institute of Tropical Agriculture (IITA). https://doi.org/10.25502/20180730/1134/MA",
		uri = uri,
		group=group,
 	    publication="doi:10.1016/j.jenvman.2017.06.058",
		carob_contributor = "Robert Hijmans",
		data_type = "experiment",
		project="International Maize Trials",
		data_institutions="IITA"
	)

	
	## download and read data 
	ff  <- carobiner::get_data(uri, path, group)
	js <- carobiner::get_metadata(dataset_id, path, major=2, minor=1, group)
	dset$license <- carobiner::get_license(js)

	mzfun <- carobiner::get_function("intmztrial_striga", path, group)

	d <- mzfun(ff)
	d$dataset_id <- dataset_id
	d$country <- "Benin"
	
	i <- d$location == "Bagou"
	d$latitude[i] <- 10.70
	
	carobiner::write_files(dset, d, path=path)

}



