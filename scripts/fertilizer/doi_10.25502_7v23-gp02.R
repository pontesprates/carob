# R script for "carob"

## ISSUES
# ....


carob_script <- function(path) {
  
  "
	Description:

    N2Africa is to contribute to increasing biological nitrogen fixation 
    and productivity of grain legumes among African smallholder farmers 
    which will contribute to enhancing soil fertility, improving household
    nutrition and increasing income levels of smallholder farmers. 
    As a vision of success, N2Africa will build sustainable, long-term 
    partnerships to enable African smallholder farmers to benefit from 
    symbiotic N2-fixation by grain legumes through effective production 
    technologies including inoculants and fertilizers adapted to local settings. 
    A strong national expertise in grain legume production and N2-fixation research 
    and development will be the legacy of the project.
      
"
  uri <- "doi.org/10.25502/7v23-gp02"
  dataset_id <- carobiner::simple_uri(uri)
  group <- "fertilizer"
 
   ## dataset level data 
  dset <- data.frame(
    dataset_id = dataset_id,
    group=group,
    project="N2Africa",
    uri=uri,
    publication=NA,
    data_citation = 'Vanlauwe, B., Adjei-Nsiah, S., Woldemeskel, E., Ebanyat, P., Baijukya, F., Sanginga, J.-M., Woomer, P., Chikowo, R., Phiphira, L., Kamai, N., Ampadu-Boakye, T., Ronner, E., Kanampiu, F., Giller, K., Ampadu-Boakye, T., & Heerwaarden, J. van. (2020). N2Africa agronomy trials - Uganda, 2016, I [Data set]. International Institute of Tropical Agriculture (IITA). https://doi.org/10.25502/6H5E-Q472',
    data_institutions = "IITA",
    carob_contributor="Eduardo Garcia Bendito",
    data_type="experiment"
  )
  
  ## download and read data 
  ff <- carobiner::get_data(uri, path, group)
  js<-carobiner::get_metadata(dataset_id,path,group,major=1,minor = 0)
  dset$license <-carobiner::get_license (js)
 
  #read the data file
  f1 <- ff[basename(ff) == "general.csv"]
  # f2 <- ff[basename(ff) == "production.csv"] 
  f3 <- ff[basename(ff) == "experiment.csv"] 
  # read the dataset
  d1 <- data.frame(read.csv(f1))
  # d2 <- data.frame(read.csv(f2))
  d3 <- data.frame(read.csv(f3))
  
  # Subset d1
  colnames(d1)[c(3,4,5,6,8,9)] <- c("trial_id", "obs_day", "obs_month", "obs_year", "adm1", "adm2")
  colnames(d1)[c(59,60,61)] <- c("harvest_date_day", "harvest_date_month", "harvest_date_year")
  d1 <- d1[,c("trial_id", "obs_day", "obs_month", "obs_year", "adm1", "adm2","harvest_date_day", "harvest_date_month", "harvest_date_year")]
  d1$country <- "Tanzania"
  d1$adm1 <- trimws(tools::toTitleCase(tolower(d1$adm1)))
  d1$adm2 <- trimws(tools::toTitleCase(tolower(d1$adm2)))
  d1$adm1[grep("Moshi", d1$adm1, value = F)] <- "Moshi Rural"
  d1$adm2[grep("Mwika", d1$adm2, value = F)] <- "Mwika South"
  # # Subset d2
  # d2 <- d2[,c(3:8,13:16,49:52,65:81,133:138)]
  # colnames(d2) <- c("trial_id", "area_field1", "area_field2", "area_field2", "area_field3", "area_field4", "area_field_unit",
  #                   "main_crop_field1", "main_crop_field2", "main_crop_field3", "main_crop_field4",
  #                   "variety_field1", "variety_field2", "variety_field3", "variety_field4",
  #                   "amount_mineral_fertilizer_field1", "amount_mineral_fertilizer_field2", "amount_mineral_fertilizer_field3", "amount_mineral_fertilizer_field4","amount_fertilizer_unit",
  #                   "fertilizer_type_field1", "fertilizer_type_field2", "fertilizer_type_field3", "fertilizer_type_field4",
  #                   "OM_used_field1", "OM_used_field2", "OM_used_field3", "OM_used_field4",
  #                   "innocuated_field1", "innocuated_field2", "innocuated_field3", "innocuated_field4",
  #                   "50pct_flowering_day", "50pct_flowering_month", "50pct_maturity_day", "50pct_maturity_month")
  # Subset d3
  d3 <- d3[,c(3,5:12,86:297)]
  d3 <- cbind(d3[,c(1:7)],
              d3[,c(grep(paste0("plot_",1:6, collapse = "|"), colnames(d3[10:ncol(d3)]), value = T))],
              d3[,c(grep("experimental_treatments_", colnames(d3[10:ncol(d3)]), value = T))])
  # reshape d3
  rr <- reshape(d3,
              direction='long', 
              varying=list(names(d3)[8:ncol(d3)]),
              v.names = "value",
              idvar = "farm_id",
              timevar = "var",
              times = colnames(d3)[8:ncol(d3)])
  rownames(rr) <- 1:nrow(rr)
  for(i in 1:6){
    rrr <- reshape(rr[rr$var %in% grep(paste0(paste0("plot_",i), "|experimental_treatments_"), rr$var, value = T),
                      c("farm_id", paste0("name_treatment_",i), "var", "value")],
           idvar = c("farm_id", paste0("name_treatment_",i)), timevar = "var",
           direction='wide')
    rrr$plot <- i
    colnames(rrr) <- gsub("value.", "", colnames(rrr))
    colnames(rrr) <- gsub(paste0("_plot_",i), "", colnames(rrr))
    colnames(rrr)[1:2] <- c("trial_id", "treatment")
    colnames(rrr) <- gsub("\\..*", "", colnames(rrr))
    colnames(rrr)[c(3,4,6,7,8)] <- c("plot_width", "plot_length", "yield", "residue", "biomass_total")
    if(i == 1){d <- rrr}
    else{d <- rbind(d,rrr)}
  }
  
  # Merge site info and agronomy info
  d <- merge(d, d1, by = "trial_id")
  
  # Standardization
  d$trial_id <- paste(d$trial_id, d$plot, sep = "_")
  d$country <- "Tanzania"
  d$date <- paste(as.integer(d$obs_year),
                  ifelse(d$obs_month == 'December', as.integer(12), as.integer(11)),
                  sprintf('%02d', d$obs_day),
                  sep = "-")
  # # EGB:
  # # This is not included because how can harvest date be after the survey?
  # d$harvest_date <- paste(as.integer(d$harvest_date_year),
  #                         ifelse(d$harvest_date_month == 'January', '01', '02'),
  #                         sprintf('%02d', d$harvest_date_day),
  #                         sep = "-")
  d$on_farm <- TRUE
  d$is_survey <- TRUE
  # d$treatment <- 
  d$crop <- "common bean"
  d$variety <- 'Lyamungo 90'
  
  # Fertilizer part
  d$fertilizer_type <- 'none'
  d$fertilizer_type[grepl('\\+', d$treatment)] <- "PKS"
  d$fertilizer_type[grep('pk', d$treatment)] <- "PKS"
  d$fertilizer_type[grep('npk', d$treatment)] <- "NPK"
  d$fertilizer_type[grepl('mpal', d$treatment)] <- "sympal"
  d$N_fertilizer <- 0
  d$N_fertilizer <- ifelse(d$fertilizer_type == "NPK",
                           ((as.numeric(d$fert_1_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0.1, # Assumed to be NPK (10:18:24)
                           d$N_fertilizer)
  d$N_fertilizer <- ifelse(d$fertilizer_type == "PKS",
                           ((as.numeric(d$fert_2_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0, # PK has 0 % N
                           d$N_fertilizer)
  d$N_fertilizer <- ifelse(d$fertilizer_type == "sympal",
                           ((as.numeric(d$fert_3_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0, # Sympal has 0 % N
                           d$N_fertilizer)
  d$P_fertilizer <- 0
  d$P_fertilizer <- ifelse(d$fertilizer_type == "NPK",
                           ((as.numeric(d$fert_1_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0.18, # Assumed to be NPK (10:18:24)
                           d$P_fertilizer)
  d$P_fertilizer <- ifelse(d$fertilizer_type == "PKS",
                           ((as.numeric(d$fert_2_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0.18, # Assumed to be PK (18:24)
                           d$P_fertilizer)
  d$P_fertilizer <- ifelse(d$fertilizer_type == "sympal",
                           ((as.numeric(d$fert_3_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0.23, # Sympal has 0 % N
                           d$P_fertilizer)
  d$K_fertilizer <- 0
  d$K_fertilizer <- ifelse(d$fertilizer_type == "NPK",
                           ((as.numeric(d$fert_1_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0.24, # Assumed to be NPK (10:18:24)
                           d$K_fertilizer)
  d$K_fertilizer <- ifelse(d$fertilizer_type == "PKS",
                           ((as.numeric(d$fert_2_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0.24, # Assumed to be PK (18:24)
                           d$K_fertilizer)
  d$K_fertilizer <- ifelse(d$fertilizer_type == "sympal",
                           ((as.numeric(d$fert_3_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000) * 0.15, # Sympal has 0 % N
                           d$K_fertilizer)
  d$N_fertilizer[which(is.na(d$N_fertilizer))] <- 0
  d$P_fertilizer[which(is.na(d$P_fertilizer))] <- 0
  d$K_fertilizer[which(is.na(d$K_fertilizer))] <- 0
  d$OM_used <- NA
  d$OM_used[grepl('\\+', d$treatment)] <- TRUE
  d$OM_type <- ifelse(d$OM_used == TRUE, "farmyard manure", NA)
  d$OM_applied <- ifelse(d$OM_used == TRUE,
                         ((as.numeric(d$manure_kg_plot) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000),
                         NA)
  # Yield
  d$yield <- (as.numeric(d$yield) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000 # kg/ha
  d$yield_part <- "seed"
  d$residue_yield <- (as.numeric(d$residue) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000 # kg/ha
  d$biomass_total <- (as.numeric(d$biomass_total) / (as.numeric(d$plot_width)*as.numeric(d$plot_length))) * 10000 # kg/ha
  
  # Other
  d$irrigated <- FALSE
  d$row_spacing <- as.numeric(d$experimental_treatments_density_1_row_spacing)
  d$plant_spacing <- as.numeric(d$experimental_treatments_density_1_plant_spacing)
  d$plant_density <- (as.numeric(d$plot_width)/(as.numeric(d$row_spacing)/100)) * (as.numeric(d$plot_length)/(as.numeric(d$plant_spacing)/100)) # plants/plot
  d$plant_density <- (as.numeric(d$plant_density) / (as.numeric(d$plot_width)*as.numeric(d$plot_length)) * 10000) # plants/ha
  
  # # EGB:
  # # There is info on herbicide
  
  # Add geo
  s <- data.frame(country = c("Tanzania", "Tanzania", "Tanzania","Tanzania", "Tanzania", "Tanzania", "Tanzania", "Tanzania", "Tanzania", "Tanzania"),
                  adm1 = c("Lushoto", "Lushoto", "Lushoto", "Lushoto", "Lushoto", "Lushoto", "Lushoto", "Moshi Rural", "Moshi Rural", "Moshi Rural"),
                  adm2 = c("Lushoto", "Kwemashai", "Shume", "Migambo", "Manoro", "Mwangoi", "Dule m", "Makuyuni", "Marangu East", "Mwika South"),
                  latitude = c(-4.545, -4.806, -4.7, -4.545, -4.545, -4.603, -4.545, -3.402, -3.283, -3.283),
                  longitude = c(38.439, 38.328, 38.216, 38.439, 38.439, 38.313, 38.439, 37.57, 37.516, 37.583))
  d <- merge(d,s, by = c("country", "adm1", "adm2"))
  
  # Subset final
  d <- d[,c('trial_id','treatment','country','adm1','adm2','longitude','latitude',
            'date','on_farm','is_survey','crop','variety',
            'fertilizer_type','N_fertilizer','P_fertilizer','K_fertilizer','OM_used','OM_type','OM_applied',
            'yield', 'yield_part', 'residue_yield', 'biomass_total',
            'irrigated', 'row_spacing', 'plant_spacing', 'plant_density')]
  d$dataset_id <- dataset_id
  
  carobiner::write_files (dset, d, path=path)
  
}

# # EGB: Georeferencing
# s <- unique(d1[,c("country", "adm1", "adm2")])
# s$latitude <- NA
# s$longitude <- NA
# s$latitude[grep("Lushoto", s$adm1)] <- -4.545 # https://www.geonames.org/155568/lushoto.html
# s$longitude[grep("Lushoto", s$adm1)] <- 38.439 # https://www.geonames.org/155568/lushoto.html
# s$latitude[grepl("Moshi", s$adm1)] <- -3.362 # https://www.geonames.org/7840035/moshi-rural-district.html
# s$longitude[grepl("Moshi", s$adm1)] <- 37.459 # https://www.geonames.org/7840035/moshi-rural-district.html
# s$latitude[grep("Mwika South", s$adm2)] <- -3.283 # https://www.geonames.org/152120/mwika.html
# s$longitude[grep("Mwika South", s$adm2)] <- 37.583 # https://www.geonames.org/152120/mwika.html
# s$latitude[grep("Marangu East", s$adm2)] <- -3.283 # https://www.geonames.org/154777/marangu.html
# s$longitude[grep("Marangu East", s$adm2)] <- 37.516 # https://www.geonames.org/154777/marangu.html
# s$latitude[grep("Makuyuni", s$adm2)] <- -3.402 # https://www.geonames.org/11004800/makuyuni.html
# s$longitude[grep("Makuyuni", s$adm2)] <- 37.57 # https://www.geonames.org/11004800/makuyuni.html
# s$latitude[grep("Dule M", s$adm2)] <- -4.563 # https://www.geonames.org/11006908/dule-m.html
# s$longitude[grep("Dule M", s$adm2)] <- 38.309 # https://www.geonames.org/11006908/dule-m.html
# s$latitude[grep("Mwangoi", s$adm2)] <- -4.603 # https://www.geonames.org/11007048/mwangoi.html
# s$longitude[grep("Mwangoi", s$adm2)] <- 38.313 # https://www.geonames.org/11007048/mwangoi.html
# s$latitude[grep("Shume", s$adm2)] <- -4.7 # https://www.geonames.org/149973/shume.html
# s$longitude[grep("Shume", s$adm2)] <- 38.216 # https://www.geonames.org/149973/shume.html
# s$latitude[grep("Kwemashai", s$adm2)] <- -4.806 # https://www.geonames.org/11006961/kwemashai.html
# s$longitude[grep("Kwemashai", s$adm2)] <- 38.328 # https://www.geonames.org/11006961/kwemashai.html
# s <- dput(s)
