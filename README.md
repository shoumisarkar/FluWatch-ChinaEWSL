R codes for the spatio-temporal monitoring framework described in our paper "Online Monitoring and Early Detection of Influenza Outbreaks Using the Exponentially Weighted Spatial LASSO: A Case Study in China During 2014-2020", by Shoumi Sarkar, Yuhang Zhou, Yang Yang, Peihua Qiu.

`01_IR_map_panel.R` creates an aggregated map of incidence rates (IRs) for specified periods (Figure 1 in the article). This helps determine the IC and OC years.

`02a_Monitor2015.R` - `02e_Monitor2019.R` contain codes for the spatio-temporal monitoring for the respective years 2015-2019.

`03_EWSL_control_charts_and_comparison_maps.Rmd` contains codes for generating the EWSL control charts in Figures 3(a) - 7(a), and the RShiny app that outputs the comparison maps in Figures 3(b) - 7(b).
