library(gridExtra)
library(ggplot2)
library(data.table)
library(rgdal)
library(readxl)

# Set Working Directory
setwd("path/to/input/files")
# Load Dataset
Influenza <- read_excel("Influenza.xlsx")

# Read Shapefile
china_map=readOGR(dsn=("china_map_province_prefecture"),layer="dishi")
data.table::setnames(china_map@data,"PYNAME","city")

# Adjusting city names
dataset_cities = paste0(Influenza$city, " Shi")

# Manually created matching city names
matching_citynames <- read_excel("matching_citynames.xlsx")
matching_citynames$city_province_name = NA
for(i in 1:nrow(matching_citynames)){
  ind = which(Influenza$city %in% matching_citynames$dataset_city_name[i])
  matching_citynames$city_province_name[i] = Influenza$city_province_name[ind]
}

# Add a column to shapefile
china_map@data$city_province_name_from_Influenza_dataset = NA
for(i in 1:length(china_map@data$city)){
  ind1 = which(dataset_cities %in% china_map@data$city[i])
  ind2 = which(matching_citynames$shapefile_city_name %in% china_map@data$city[i])
  
  if(length(ind1)>0) {
    china_map@data$city_province_name_from_Influenza_dataset[i] = unique(Influenza$city_province_name[ind1])[1]
  }
  if(length(ind2>0)){
    china_map@data$city_province_name_from_Influenza_dataset[i] = matching_citynames$city_province_name[ind2]
  }
}

# Prepare to store plots
plot_list <- list()

# Determine the overall scale based on dataset's rates
overall_min <- min(Influenza$rate, na.rm = TRUE)
overall_max <- quantile(Influenza$rate, 0.99, na.rm = TRUE)

# Plotting for the given years and months
save_plots = function(y1, y2, y3)
{
  
  for(month in c("June", "December")){
    ###Adjust c(2014, 2015, 2016) to be your desired years.
    for(y in c(y1, y2, y3)){
      if (month == "June"){
        Influenza_subdat = subset(Influenza, week==26 & year==y)
      } else {
        Influenza_subdat = subset(Influenza, week==50 & year==y)
      }
      
      china_map@data$rate = 0
      for(i in 1:nrow(china_map@data)){
        if(china_map@data$city_province_name_from_Influenza_dataset[i] %in% Influenza_subdat$city_province_name){
          ind = which(Influenza_subdat$city_province_name %in% china_map@data$city_province_name_from_Influenza_dataset[i])
          china_map@data$rate[i] = Influenza_subdat$rate[ind]
        }
      }
      
      ChinaProvince.tidy <- ggplot2::fortify(china_map, region="city")
      china_map@data$id <- china_map@data$city
      ChinaProvince.tidy <- merge(ChinaProvince.tidy, china_map@data, by="id")
      
      map_ChinaProvince <- ggplot(data=ChinaProvince.tidy,
                                  aes(long, lat, group=group, fill=rate)) +
        geom_polygon() +
        geom_path(color = 'black', size=0.001) +
        scale_fill_gradient(low = 'white', high = 'black',
                            limits=c(overall_min, overall_max)) +
        coord_equal() +
        theme(axis.title = element_blank(),
              axis.text = element_blank(),
              legend.position = "none") + 
        labs(title = paste0(month, " ", y)) + 
        theme_void() + 
        theme(plot.title = element_text(size = 40)) + # Increase title size
        theme(plot.margin = margin(0, 0, 0, 0)) +
        theme_void()
      plot_list[[paste0(month, "_", y)]] <- map_ChinaProvince
    }
  }
  g_legend <- function(a.gplot){
    tmp <- ggplot_gtable(ggplot_build(a.gplot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    return(legend)
  }
  # Extracting legend
  legend_grob <- g_legend(map_ChinaProvince)
  
  # Combine the plots with the legend
  combined_plot <- grid.arrange(grobs=c(plot_list, list(legend_grob)), 
                                ncol=3, nrow=3, 
                                layout_matrix=rbind(c(1,2,3), c(4,5,6), c(7,7,7)))
  
  # Save to a single PDF
  filename = paste0("Maps_", paste(y1, y2, y3, sep = ","), ".pdf")
  setwd("path/to/save/plots")
  ggsave(filename, plot=combined_plot, width=27, height=18)
}

###############################################
##### Setup 1: Three consecutive years ########
###############################################

save_plots(2014, 2015, 2016)
save_plots(2015, 2016, 2017)
save_plots(2016, 2017, 2018)
save_plots(2017, 2018, 2019)
save_plots(2018, 2019, 2020)

###################################################
## Setup 2: Fix 2014 & 2015, vary monitored year ##
###################################################

save_plots(2014, 2015, 2016)
save_plots(2014, 2015, 2017)
save_plots(2014, 2015, 2018)
save_plots(2014, 2015, 2019)
save_plots(2014, 2015, 2020)
