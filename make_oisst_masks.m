function make_oisst_masks
% ===================================
% Make masks to handle special cases for thermal displacement
% (e.g., can't move from a lake to another body of water)
%
% Mask are called by apply_oisst_masks.m, which in turn is called
% by thermal_displacement.m
%
% These masks were developed through trial and error, ensuring
% thermal displacements are realistic on a global scale.
% Further refinement is surely possible.
%
% M. Jacox 2020
% ===================================

% Output file
fout = '~/Dropbox/MHW/Data/oisst_masks';

fprintf('\nMaking regional masks...\n')

% Load land and ice masks
load ~/Dropbox/MHW/Data/oisst_an_1982-2019 lon lat lsm
load ~/Documents/Data/OISST/OISST_25km_monthly/oisst_25km_monthly_ice_mask_1982-2019 ice_mask

% Make mask
[nx,ny] = size(lsm);
mask = nan(nx,ny);

% Land
mask(lsm==1) = 0;

% Permanent sea ice
mask(mean(ice_mask,3)>.9 & isnan(mask)) = 1;
mask_names{1} = 'Permanent sea ice';

% Seasonal sea ice
mask(mean(ice_mask,3)>0 & isnan(mask)) = 2;
mask_names{2} = 'Seasonal sea ice';

% Ice-free areas surrounded by sea ice
mask(lat<-63.9 & isnan(mask)) = 3; % Antarctica
mask(lon>12 & lon<32 & lat>53.5 & lat<=66 & isnan(mask)) = 3; % Baltic
mask(lon>9.9 & lon<12 & lat>53 & lat<=60 & isnan(mask)) = 3; % Baltic
mask(lon>36 & lon<46 & lat>63 & lat<=67 & isnan(mask)) = 3; % White
mask(lon>14 & lon<24 & lat>77 & lat<=81 & isnan(mask)) = 3; % Svalbard
mask(lon>50 & lon<190 & lat>60 & lat<=88 & isnan(mask)) = 3; % Russia
mask(lon>136 & lon<139 & lat>53 & lat<=54 & isnan(mask)) = 3; % Russia
mask(lon>158 & lon<159 & lat>52 & lat<=54 & isnan(mask)) = 3; % Russia
mask(lon>160 & lon<163 & lat>57 & lat<=60 & isnan(mask)) = 3; % Russia
mask(lon>193 & lon<207.8 & lat>57 & lat<=68 & isnan(mask)) = 3; % Alaska
mask(lon>207 & lon<213 & lat>60 & lat<=62 & isnan(mask)) = 3; % Alaska
mask(lon>228 & lon<320 & lat>62.5 & lat<=85 & isnan(mask)) = 3; % Canada/Greenland
mask(lon>267 & lon<284 & lat>51 & lat<=63 & isnan(mask)) = 3; % Canada
mask(lon>333 & lon<341 & lat>70 & lat<=84 & isnan(mask)) = 3; % Greenland
mask(lon>338 & lon<345 & lat>64.5 & lat<=68 & isnan(mask)) = 3; % Iceland
mask(lon>267 & lon<285 & lat>41 & lat<=50 & isnan(mask)) = 3; % Great Lakes
mask(lon>290 & lon<297 & lat>45 & lat<=50 & isnan(mask)) = 3; % NW Atlantic
mask(lon>302 & lon<307 & lat>47 & lat<=54 & isnan(mask)) = 3; % NW Atlantic
mask_names{3} = 'Ice-surrounded areas';

% Caspian Sea
mask(lon>=46 & lon<=56 & lat>=36 & lat<=48 & isnan(mask)) = 4;
mask_names{4} = 'Caspian Sea';

% Black Sea
mask(lon>=26.8 & lon<=42 & lat>=40 & lat<=48 & isnan(mask)) = 5;
mask_names{5} = 'Black Sea';
 
% Mediterranean Sea
mask(lon<=26.7 & lat>=30 & lat<=46 & isnan(mask)) = 6;
mask(lon>=26 & lon<=37 & lat>=30.5 & lat<=39.5 & isnan(mask)) = 6;
mask(lon>=354 & lat>=33 & lat<=41 & isnan(mask)) = 6;
mask_names{6} = 'Mediterranean Sea';

% Red Sea
mask(lon>=32 & lon<=43 & lat>=12.5 & lat<=30 & isnan(mask)) = 7;
mask_names{7} = 'Red Sea';

% Persian Gulf
mask(lon>=46 & lon<56 & lat>=23 & lat<=31 & isnan(mask)) = 8;
mask_names{8} = 'Persian Gulf';

% Northern Arabian Sea
mask(lon>=45 & lon<75 & lat>=14 & lat<=28 & isnan(mask)) = 9;
mask_names{9} = 'Northern Arabian Sea';

% Northern Bay of Bengal
mask(lon>=77 & lon<99 & lat>=14 & lat<=25 & isnan(mask)) = 10;
mask_names{10} = 'Northern Bay of Bengal';

% Equatorial Indian Ocean
mask(lon>=37 & lon<99 & lat>=-5 & lat<=15 & isnan(mask)) = 11;
mask(lon>=99 & lon<=100 & lat>=-5 & lat<8 & isnan(mask)) = 11;
mask(lon>100 & lon<=101 & lat>=-5 & lat<6.7 & isnan(mask)) = 11;
mask(lon>101 & lon<=104 & lat>=-5 & lat<-2 & isnan(mask)) = 11;
mask_names{11} = 'Equatorial Indian Ocean';

% South China Sea
mask(lon>=98 & lon<120 & lat>=-5 & lat<=30 & isnan(mask)) = 12;
mask_names{12} = 'South China Sea';

% Northern Gulf of California
mask(lon>=244.5 & lon<248 & lat>=29.7 & lat<=32 & isnan(mask)) = 13;
mask(lon>=245.5 & lon<249 & lat>=29.4 & lat<=30 & isnan(mask)) = 13;
mask(lon>=246 & lon<249 & lat>=28.9 & lat<=30 & isnan(mask)) = 13;
mask(lon>=246.5 & lon<252 & lat>=27 & lat<=30 & isnan(mask)) = 13;
mask(lon>=247.8 & lon<252 & lat>=26.4 & lat<=30 & isnan(mask)) = 13;
mask(lon>=248.2 & lon<252 & lat>=25 & lat<=30 & isnan(mask)) = 13;
mask_names{13} = 'Northern Gulf of California';

% Eastern Tropical Pacific
mask(lon>=245 & lon<260 & lat>=0 & lat<=25 & isnan(mask)) = 14;
mask(lon>=255 & lon<262 & lat>=0 & lat<=20 & isnan(mask)) = 14;
mask(lon>=261 & lon<270 & lat>=0 & lat<=17 & isnan(mask)) = 14;
mask(lon>=269 & lon<275.7 & lat>=0 & lat<=14 & isnan(mask)) = 14;
mask(lon>=269 & lon<282.8 & lat>=0 & lat<=7.4 & isnan(mask)) = 14;
mask(lon>=269 & lon<282 & lat>=0 & lat<=8.5 & isnan(mask)) = 14;
mask(lon>=275 & lon<277 & lat>=8.4 & lat<=9.5 & isnan(mask)) = 14;
mask(lon>=280 & lon<281.6 & lat>=8.4 & lat<=9 & isnan(mask)) = 14;
mask(lon>=245 & lon<295 & lat>=-30 & lat<=0 & isnan(mask)) = 14;
mask_names{14} = 'Eastern Tropical Pacific';

% Northern Gulf of Mexico
mask(lon>=260 & lon<278.5 & lat>=27 & lat<=31 & isnan(mask)) = 15;
mask_names{15} = 'Northern Gulf of Mexico';

% Western Tropical Atlantic
mask(lon>=260 & lon<315 & lat>=-10 & lat<=27 & isnan(mask)) = 16;
mask_names{16} = 'Western Tropical Atlantic';

% US East Coast
mask(lon>=278.5 & lon<315 & lat>=27 & lat<=47 & isnan(mask)) = 17;
mask_names{17} = 'US East Coast';

% Plot mask
figure,set(gcf,'color','w'),hold on
pcolor(lon,lat,mask)
shading interp
colormap(jet(max(mask(:))+1));
caxis([-.5 max(mask(:))+.5])
contour(lon,lat,lsm,[.9 .9],'k')
colorbar
set(gca,'color','m')

% Save
fprintf('Saving to %s\n',fout)
save(fout,'lon','lat','mask','mask_names')