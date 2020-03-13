function d_mask = apply_oisst_masks(ii,jj,d,mask,lat,lon)
% ====================================================
% Apply region-dependent masks to OISST distance field
%
%   d_mask = apply_oisst_masks(ii,jj,d,mask,lat,lon)
%
% Inputs:
%       ii: longitude index on OISST grid
%       jj: latitude index on OISST grid
%       d:  matrix of distances to all other OISST grid cells
%           from point (ii,jj). Dimensions are [lon lat]
%       mask: mask defining regions, created by make_oisst_masks.m
%             Dimensions are [lon lat]
%       lat:  Matrix of OISST latitudes
%       lon:  Matrix of OISST longitudes
%
% Output:
%       d_mask: matrix of distances with unavailable locations masked out
%
% This function limits the locations that are classified
% as available for thermal displacements (e.g., for heatwaves
% in the Caspian Sea the thermal displacement cannot be outside
% the Caspian Sea. This script is called by
% thermal_displacement.m
%
% Exclusions are mostly based on the mask created in
% make_oisst_masks.m. As is the case for that script, this one
% could be modified to change which regions are considered
% accessible from any given location.
%
% Masks applied are below, with numbers referring to regions in 
% the mask file
%
% 4: Caspian Sea
%   only 4
%
% 5: Black Sea
%   only 5
%
% 6: Mediterranean Sea
%   exclude 2-5,7-8, >48N, >43N & >351
%   For northern Adriatic, only Med Sea
% 
% 7: Red Sea
%   only 7,11
%
% 8: Persian Gulf
%   only 8,9
%
% 9: Northern Arabian Sea
%   only 7,8,9,11
% 
% 10: Northern Bay of Bengal
%   only 10,11
%
% 11: Equatorial Indian Ocean
%   exclude 4-6,12
%
% 12: South China Sea
%   exclude 9-11
% 
% 13: Northern Gulf of California
%   limit to Gulf + ETP
%
% 14: Eastern Tropical Pacific
%   exclude 15-17, >283
%
% 15: Northern Gulf of Mexico
%   exclude 13,14,17, N. Pacific, seasonal sea ice, >280
%
% 16: Western Tropical Atlantic
%   exclude 13,14, N. Pacific
%
% 17: US East Coast
%   exclude 15
% ====================================================

d_mask = d;

% Exclude ice-surrounded areas
d_mask(mask==3) = nan;

% Handle regional cases
switch mask(ii,jj)
    case 4
        d_mask(mask~=4) = nan;
    case 5
        d_mask(mask~=5) = nan;
    case 6
        d_mask(mask<=5 | mask==7 | mask==8 | lat>48 | (lat>43 & lon>351)) = nan;
        if lon(ii,jj)>12 & lon(ii,jj)<20 & lat(ii,jj)>42.3 & lat(ii,jj)<46
            d_mask(mask~=6) = nan;
        end
    case 7
        d_mask(~(mask==7 | mask==11)) = nan;
    case 8
        d_mask(~(mask==8 | mask==9)) = nan;
    case 9
        d_mask(~(mask==7 | mask==8 | mask==9 | mask==11)) = nan;
    case 10
        d_mask(~(mask==10 | mask==11)) = nan;
    case 11
        d_mask((mask>=4 & mask<=6) | mask==12) = nan;
    case 12
        d_mask(mask>=9 & mask<=11) = nan;
    case 13
        d_mask(~(mask==13 | mask==14)) = nan;
    case 14
        d_mask((mask>=15 & mask<=17) | lat>283) = nan;
    case 15
        d_mask(mask==2 | mask==13 | mask==14 | mask==17 | lon<260 | lon>280) = nan;
    case 16
        d_mask(mask==13 | mask==14 | lon<260) = nan;
    case 17
        d_mask(mask==15) = nan;
end