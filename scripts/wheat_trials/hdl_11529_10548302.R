# R script for "carob"

## ISSUES
# ....


carob_script <- function(path) {

"Description:
The Semi-Arid Wheat Yield Trial (SAWYT) is a replicated yield trial that contains spring bread wheat (Triticum aestivum) germplasm adapted to low rainfall, drought prone environments typically receiving less than 500 mm of water available during the cropping cycle. The combination of water-use efficiency and water responsive broad adaptation plus yield potential is important in drought environments where rainfall is frequently erratic across and within years. Stripe rust, leaf rust and stem rust, root rots, nematodes, and bunts are the key biotic constraints. Typical target environments include winter rain or Mediterranean-type drought associated with post-flowering moisture stress and heat stress such as those found at Aleppo (Syria), Settat (Morocco) and Marcos Juarez (Argentina), all classified by CIMMYT within Wheat Mega Environment 4 (Low rainfall, semi-arid environment; ME4: SA). It is distributed to 150 locations, and contains 50 entries. (2018)"

	uri <- "hdl:11529/10548302"
	dataset_id <- carobiner::simple_uri(uri)
	group <- "wheat_trials"
	## dataset level data 
	dset <- data.frame(
	   dataset_id = dataset_id,
	   group=group,
	   uri=uri,
	   project="CIMMYT Semi-Arid Wheat Yield Trial",	   
	   publication=NA,
	   data_citation = "Global Wheat Program; IWIN Collaborators; Singh, Ravi; Payne, Thomas, 2019. 26th Semi-Arid Wheat Yield Trial. https://hdl.handle.net/11529/10548302, CIMMYT Research Data & Software Repository Network, V5",
	   data_institutions = "CIMMYT",
	   carob_contributor="Robert Hijmans",
	   data_type="on-station experiment"
 	)

## download and read data 

	ff  <- carobiner::get_data(uri, path, group)
	js <- carobiner::get_metadata(dataset_id, path, group, major=5, minor=0)
	dset$license <- carobiner::get_license(js)

## process file(s)
	proc_wheat <- carobiner::get_function("proc_wheat", path, group)
	d <- proc_wheat(ff)
	d$dataset_id <- dataset_id

# all scripts must end like this
	carobiner::write_files(dset, d, path=path)
}

