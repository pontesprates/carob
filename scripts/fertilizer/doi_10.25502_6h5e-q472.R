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
    
    %%%%%%%%%%The dataset is N2Africa agronomy trials - Uganda, 2016, I%%%%%%%%%%%%
    Crop: Climbing bean
    Crop system: intercropped with banana vs. sole
  
"
  uri <- "doi.org/10.25502/6h5e-q472"
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
    carob_contributor="Samar Attaher",
    data_type="experiment"
  )
  
  ## download and read data 
  ff <- carobiner::get_data(uri, path, group)
  js<-carobiner::get_metadata(dataset_id,path,group,major=1,minor = 0)
  dset$license <-carobiner::get_license (js)
 
  #read the data file
  f <- ff[basename(ff) == "data_table.csv"] 
  # read the dataset
  d <- data.frame(read.csv(f))

  #change the columns names...********issue: the original names returns errors in columns selection**********  
  colnames(d)[2]<-"trial_id"
  colnames(d)[8:9]<- c("country","adm2")
  colnames(d)[11:13]<-c("latitude","longitude","elevation")
  colnames(d)[16:19] <- c("site","farm_size_ha","farm_size_unit","crop")
  colnames(d)[28:29]<- c("fertilizer_type","OM_type")
  colnames(d)[83:86]<- c("field_slop","farmer_perception_fertility","relative_fertility","drainage_level")
  colnames(d)[92:109]<- c("previous_crop","other_previous_crop","fertilizer_type_previous_season","organic_fertilizer_previous_season",
                          "inoculated_previous_season","area_harvested_previous_season","unit_area_harvested_previous_season",
                          "yield_previous_season","unit_yield_previous_season","previous_crop_before_previous_season",
                          "other_previous_crop_before_previous_season","fertilizer_type_before_previous_season",
                          "OM_type_before_previous_season","inoculated_before_previous_season","area_harvested_before_previous_season",
                          "unit_area_harvested_before_previous_season","yield_crop_before_previous_season",
                          "unit_yield_crop_before_previous_season")
  
  colnames(d)[122:127]<-c("land_preparation_date","OM_application_date","planting_date",
                          "fertilizer_application_date","frist_weeding_date","second_weeding_date")
  colnames(d)[130:132]<-c("insecticide_application_date","drought_period_beginning_date","drought_period_end_date")
  colnames(d)[136:139]<-c("pest_disease_date","flowering_date","maturity_date","harvest_date_date")
 

 #new dataframe for the selected columns that descrip the full experiment (without plots data) 

  d1<- d[,c("SN", "trial_id","country","adm2","sector_ward","latitude","longitude","elevation",
            "site","farm_size_ha","farm_size_unit","field_slop","drainage_level"
            ,"crop", "fertilizer_type","OM_type","land_preparation_date",
            "OM_application_date","planting_date", "fertilizer_application_date",
            "frist_weeding_date","second_weeding_date", "insecticide_application_date",
            "drought_period_beginning_date","drought_period_end_date", 
            "pest_disease_date","flowering_date","maturity_date","harvest_date_date",
            "severity_drought","severity_water_logging","severity_pests","severity_weeds",
            "severity_disease", "type_of_pest","type_of_disease","type_of_weeds",
            "previous_crop","other_previous_crop","fertilizer_type_previous_season",
            "organic_fertilizer_previous_season","inoculated_previous_season",
            "area_harvested_previous_season","unit_area_harvested_previous_season",
            "yield_previous_season","unit_yield_previous_season",
            "previous_crop_before_previous_season","other_previous_crop_before_previous_season",
            "fertilizer_type_before_previous_season", "OM_type_before_previous_season",
            "inoculated_before_previous_season","area_harvested_before_previous_season",
            "unit_area_harvested_before_previous_season","yield_crop_before_previous_season",
            "unit_yield_crop_before_previous_season","ownership_field",
            "gender_of_farmer","farmer_perception_fertility","relative_fertility",
            "treatment1","treatment2","treatment3","treatment4", "treatment5","treatment6")] 

 # add and correct location names and georeferance colunms
  d1$adm1<- "Western"
  
  library(stringr)
  
  d1[c('adm4', 'adm5',"location")] <- str_split_fixed(d1$sector_ward,' ',3)
  d1$adm4 [d1$adm4=="Rutenga,"]<- "Rutenga"
  d1$adm4 [d1$adm4=="Mpungu,"]<- "Mpungu"
  
  d1$adm5 [d1$adm5=="Katojo,"]<- "Katojo"
  d1$adm5 [d1$adm5==",Muramba"]<- "Muramba"
  d1$adm5 [d1$adm5=="Muramba,"]<- "Muramba"
  d1$adm5 [d1$adm5=="muramba,"]<- "Muramba"
  
  d1$adm3 [d1$adm4=="Rutenga"]<- "Kinkizi East"
  d1$adm3 [d1$adm4=="Mpungu"]<- "Kinkizi West"
  
  # converting the farm size to ha....#issue: the results of some rows are not correct!
  d1$farm_size_ha[d1$farm_size_unit=="acre"] <- as.numeric(d1$farm_size_ha[d1$farm_size_unit=="acre"]*0.4) 
  
  #correct the crop name
  d1$crop<-"climbing beans"
  
  #new columns for row & plant spacing
  d1$row_spacing <- 50   
  d1$plant_spacing <- 25
  
  #correction of "none" in 
  d1$fertilizer_type_previous_season [d1$fertilizer_type_previous_season =="None"]<-NA
  d1$OM_type_before_previous_season [d1$OM_type_before_previous_season=="none"]<- NA
  d1$drought_period_beginning_date[d1$drought_period_beginning_date=='1-Jan-99']<- NA
  d1$drought_period_end_date[d1$drought_period_end_date=='1-Jan-99']<- NA
  d1$fertilizer_application_date[d1$fertilizer_application_date=='1-Jan-99']<- NA
  d1$flowering_date[d1$flowering_date=='1-Jan-99']<- NA
  d1$harvest_date_date[d1$harvest_date_date=='1-Jan-99']<- NA
  d1$maturity_date[d1$maturity_date=='1-Jan-99']<- NA 
  d1$OM_application_date[d1$OM_application_date=='1-Jan-99']<- NA
  d1$pest_disease_date[d1$pest_disease_date=='1-Jan-99']<- NA
  d1$planting_date[d1$planting_date=='1-Jan-99']<- NA
  d1$land_preparation_date [d1$land_preparation_date =='1-Jan-99']<- NA
  d1$second_weeding_date [d1$second_weeding_date =='1-Jan-99']<- NA
  d1$frist_weeding_date[d1$frist_weeding_date =='1-Jan-99']<- NA
  d1$insecticide_application_date[d1$insecticide_application_date=='1-Jan-99']<- NA
  
  
  #reshape d1 to stack the six treatments in one colunm
  
  d2<- d1[,c("SN", "trial_id","country","adm1","adm2","adm3","adm4","adm5",
            "location","latitude","longitude","elevation",
            "site","farm_size_ha","field_slop","drainage_level",
            "crop", "fertilizer_type","OM_type","land_preparation_date",
            "OM_application_date","planting_date", "fertilizer_application_date",
            "row_spacing","plant_spacing","frist_weeding_date","second_weeding_date", 
            "insecticide_application_date","drought_period_beginning_date",
            "drought_period_end_date", "pest_disease_date","flowering_date",
            "maturity_date","harvest_date_date", "severity_drought",
            "severity_water_logging","severity_pests","severity_weeds",
            "severity_disease", "type_of_pest","type_of_disease","type_of_weeds",
            "previous_crop","other_previous_crop","fertilizer_type_previous_season",
            "organic_fertilizer_previous_season","inoculated_previous_season",
            "area_harvested_previous_season","unit_area_harvested_previous_season",
            "yield_previous_season","unit_yield_previous_season",
            "previous_crop_before_previous_season","other_previous_crop_before_previous_season",
            "fertilizer_type_before_previous_season", "OM_type_before_previous_season",
            "inoculated_before_previous_season","area_harvested_before_previous_season",
            "unit_area_harvested_before_previous_season","yield_crop_before_previous_season",
            "unit_yield_crop_before_previous_season","ownership_field",
            "gender_of_farmer","farmer_perception_fertility","relative_fertility",
            "treatment1","treatment2","treatment3","treatment4", "treatment5","treatment6")]
  
  
  d3 <- data.frame(d2[1:64], stack(d2[65:ncol(d2)]))
  colnames(d3)[65:66]<- c("treatments","treatments_code")

  d3$variety<-"Nabe12c"
  d3$variety [d3$treatments_code== "treatment1" |d3$treatments_code== "treatment2"|d3$treatments_code== "treatment5"]<-"Kabweseri" 
  d3$variety [d3$SN==1 & d3$treatments_code== "treatment1"]<- "Nabe12c"
  d3$variety [d3$SN==1 & d3$treatments_code== "treatment2"]<- "Nabe12c"
  d3$variety [d3$SN==1 & d3$treatments_code== "treatment5"]<- "Nabe12c"
  d3$variety [d3$SN==1 & d3$treatments_code== "treatment3"]<- "Mubano / kabweseri"
  d3$variety [d3$SN==1 & d3$treatments_code== "treatment4"]<- "Mubano / kabweseri"
  d3$variety [d3$SN==1 & d3$treatments_code== "treatment6"]<- "Mubano / kabweseri"
  d3$variety [d3$SN==2 & d3$treatments_code== "treatment1"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==2 & d3$treatments_code== "treatment2"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==2 & d3$treatments_code== "treatment5"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==6 & d3$treatments_code== "treatment1"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==6 & d3$treatments_code== "treatment2"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==6 & d3$treatments_code== "treatment5"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==10 & d3$treatments_code== "treatment1"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==10 & d3$treatments_code== "treatment2"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==10 & d3$treatments_code== "treatment5"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==12 & d3$treatments_code== "treatment1"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==12 & d3$treatments_code== "treatment2"]<- "Mubano/kabweseri"
  d3$variety [d3$SN==12 & d3$treatments_code== "treatment5"]<- "Mubano/kabweseri"
  
  #collecting grain yield per plots and converting it to yield per hectar for each treatment
  colnames(d)[461]<-"yield_plot1"
  colnames(d)[476]<-"yield_plot2"
  colnames(d)[491]<-"yield_plot3"
  colnames(d)[506]<-"yield_plot4"
  colnames(d)[513]<-"yield_plot5"
  colnames(d)[520]<-"yield_plot6"
  
  dy<- d[,c("SN", "yield_plot1","yield_plot2","yield_plot3","yield_plot4","yield_plot5","yield_plot6")] 
  dy1 <- data.frame(dy[1], stack(dy[2:ncol(dy)]))
  dy1$yield<- dy1$values*(10000/36)   # from reference reports the area of the plot is 36 meter square 
  colnames(dy1)[3]<- "plot_number"
  d3<- cbind(d3,dy1$plot_number,dy1$yield)
  d3[c('other', 'plot_n')] <- str_split_fixed(d3$`dy1$plot_number`,'_',2)             
  d3 <- subset( d3, select = -c(other,`dy1$plot_number`))
  colnames(d3)[68]<-"yield"
  
  # # EGB: Fixing and adding
  d3$dataset_id <- dataset_id
  d3$on_farm <- TRUE
  d3$is_survey <- TRUE
  d3$variety_type <- "climbing"
  d3$yield_part <- "seed"
  # Add dates
  d3$planting_date <- as.character(as.Date(as.character(d3$planting_date), format = "%d-%b-%y"))
  d3$flowering <- as.integer(difftime(as.Date(as.character(d3$flowering_date), format = "%d-%b-%y"),
                                      as.Date(as.character(d3$planting_date), format = "%Y-%m-%d"),
                                      units = "days"))
  d3$maturity <- as.integer(difftime(as.Date(as.character(d3$maturity), format = "%d-%b-%y"),
                                     as.Date(as.character(d3$planting_date), format = "%Y-%m-%d"),
                                     units = "days"))
  d3$maturity <- ifelse(d3$maturity < 0, 365 + d3$maturity, d3$maturity) # Due to negative erroneous values (?)
  d3$harvest <- as.integer(difftime(as.Date(as.character(d3$harvest_date_date), format = "%d-%b-%y"),
                                    as.Date(as.character(d3$planting_date), format = "%Y-%m-%d"),
                                    units = "days"))
  d3$harvest <- ifelse(d3$harvest < 0, 365 + d3$harvest, d3$harvest) # Due to negative erroneous values (?)
  d3$harvest_date <- as.character(as.Date(as.character(d3$harvest_date_date), format = "%d-%b-%y"))
  # Add treatments and fertilizers
  d3$treatment <- NA
  d3$treatment[d3$treatments_code %in% c("treatment1", "treatment2")] <- "N0P0K0"
  d3$N_fertilizer <- 0
  d3$P_fertilizer <- 0
  d3$P_fertilizer[d3$treatments_code %in% c("treatment3","treatment4","treatment5","treatment6")] <- 10 * 0.1923 # Following protocol and P content in TSP
  d3$K_fertilizer <- 0
  d3$K_fertilizer[d3$treatments_code %in% c("treatment4","treatment5","treatment6")] <- 30 * 0.498 # Following protocol and K content in KCl
  d3$Zn_fertilizer <- 0
  d3$Zn_fertilizer[d3$treatments_code %in% c("treatment5","treatment6")] <- 5 * 0.365 # Following protocol and Zn content in ZnSO4
  d3$B_fertilizer <- 0
  d3$B_fertilizer[d3$treatments_code %in% c("treatment5","treatment6")] <- 5 * 0.11 # Following protocol and K content in Borax
  d3$treatment[d3$treatments_code %in% c("treatment3")] <- paste0("N0", "P", round(d3$P_fertilizer[d3$treatments_code %in% c("treatment4")], 0), "K0")
  d3$treatment[d3$treatments_code %in% c("treatment4", "treatment5", "treatment6")] <- paste0("N0",
                                                                                              "P", round(d3$P_fertilizer[d3$treatments_code %in% c("treatment4", "treatment5", "treatment6")], 0),
                                                                                              "K", round(d3$K_fertilizer[d3$treatments_code %in% c("treatment4", "treatment5", "treatment6")], 0))
  # # EGB: Process OM
  d3$OM_used <- TRUE
  d3$OM_used[d3$treatments_code == "treatment1"] <- FALSE # Assumed to be control in protocol
  d3$OM_type <- NA
  d3$OM_type[d3$treatments_code != "treatment1"] <- "farmyard manure"
  d3$OM_applied[d3$treatments_code != "treatment1"] <- 2 * 1000 # According to protocol
  # # EGB: Standardizing pathogen names
  # # Need to add pathogens/diseases to the vocabulary
  # d3$pathogen <- d3$type_of_disease
  
  d4 <- d3[,c("dataset_id", "trial_id", "on_farm", "is_survey",
              "country", "adm1", "adm2", "adm3", "adm4", "adm5", "location", "site", "elevation",
              "crop", "variety", "variety_type", "previous_crop",
              "planting_date", "flowering", "maturity", "harvest", "harvest_date",
              "treatment", "fertilizer_type", "N_fertilizer", "P_fertilizer", "K_fertilizer", 
              "OM_used", "OM_type", "OM_applied",
              "yield", "yield_part",
              # "pathogen",
              "row_spacing", "plant_spacing")]
  
  # # EGB: Improved georeferencing
  s <- data.frame(adm1 = c("Western", "Western"),
                  adm2 = c("Kanungu", "Kanungu"),
                  adm4 = c("Mpungu", "Rutenga"),
                  latitude = c(-0.99308, -0.99617),
                  longitude = c(29.72256, 29.84895))
  d5 <- merge(d4, s, by = c("adm1", "adm2", "adm4"), all.x=TRUE)
  d5$country <- "Uganda"
  d5$crop <- "common bean"
  
  carobiner::write_files (dset, d5, path=path)
  
}

# # EGB: Georeferencing
# s <- unique(d3[,c("country", "adm1", "adm2", "adm4")])
# s$latitude <- NA
# s$longitude <- NA
# for (i in 1:nrow(s)) {
#   if(is.na(s$latitude[i]) | is.na(s$longitude[i])){
#     ll <- carobiner::geocode(country = s$country[i], adm1 = s$adm1[i], adm2 = s$adm2[i], location = s$adm4[i], service = "geonames", username = "efyrouwa")
#     ii <- unlist(jsonlite::fromJSON(ll))
#     c <- as.integer(ii["totalResultsCount"][[1]])
#     s$latitude[i] <- as.numeric(ifelse(c == 1, ii["geonames.lat"][1], ii["geonames.lat1"][1]))
#     s$longitude[i] <- as.numeric(ifelse(c == 1, ii["geonames.lng"][1], ii["geonames.lng1"][1]))
#   }
# }
# s <- dput(s)
