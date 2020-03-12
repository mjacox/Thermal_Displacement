# Thermal_Displacement
Code used for analysis in Jacox et al. (2020)

## Pre-processing: 

oisst_ice_mask_monthly.m: Load OISST ice concentration and calculate monthly ice mask (ice presence/absence)

make_oisst_masks.m: Make regional masks to deal with special cases for thermal displacement (e.g., limiting movement between ocean basins, into/out of lakes)

oisst_distance.m: Calculate distance from points on OISST grid to all other points

oisst_monthly_average.m: Calculate monthly means of daily OISST



## Calculating SST anomalies:

oisst_an.m: Load OISST data, apply ice mask, and calculate anomalies. Can be detrended or not.

oisst_an_cmip_future.m: Project future SST by adding CMIP5 ensemble mean to historical OISST, calculate anomalies for the future period (relative to future climatology)



## Heatwave analysis:

define_heatwaves.m: Use OISST anomalies to define heatwaves and calculate traditional metrics (intensity, duration, frequency)

thermal_displacement.m: Calculate thermal displacement for all heatwaves (i.e., distance from heatwave location to nearest location with heatwave location’s climatological SST) 

apply_oisst_masks.m: Apply the regional masks to OISST distance fields (called by thermal_displacement.m)
