function oisst_ice_mask_monthly
% =============================
% Create monthly ice mask for 0.25 degree monthly OISST data
%
% M. Jacox, 2020
% =============================

% Input and output file directories
dirin = '~/Documents/Data/OISST/OISST_25km_daily/ice';
dirout = '~/Documents/Data/OISST/OISST_25km_monthly';

% Number of ice days in a month to classify as sea ice
ndays_ice = 15;

% NOTE ice data is missing for Dec 1987, Jan 1988, and Nov 2011
% These periods are handled near the end of the script
missing_data = [1987 12;1988 1;2011 11];

% Set years to calculate
years = [1982 2019];

% Output file
fout = sprintf('%s/oisst_25km_monthly_ice_mask_%d-%d',dirout,years(1),years(2));

% Grid size
nx = 1440;
ny = 720;
nt = length(years(1):years(2))*12;

fprintf('\nCalculating ice mask from OISST for %d-%d\n',years(1),years(2))
tic

% Create placeholders
ice_mask = zeros(nx,ny,nt);

% Loop through files
ii = 1;
for iy = years(1):years(2)
    
    fprintf('Loading %d, %.0f minutes elapsed\n',iy,toc/60)
    
    % Input file
    fname = sprintf('%s/icec.day.mean.%d.nc',dirin,iy);
    
    % Load ice data
    ice = ncread(fname,'icec');
    time = ncread(fname,'time');
    
    % Make ice binary
    ice(ice<=0) = 0;
    ice(ice>0) = 1;
    
    % Make monthly ice mask
    [~,mm,~] = datevec(datenum([1800 1 1]) + time);
    for im = 1:12
        ice_days = sum(ice(:,:,mm==im),3); % # of ice days in month
        ice_mon = zeros(size(ice_days));
        ice_mon(ice_days>ndays_ice) = 1;
        ice_mask(:,:,ii) = ice_mon;
        year(ii) = iy;
        month(ii) = im;
        ii = ii+1;
    end
end

% Calculate maximum mask extent
ice_mask_max = zeros(nx,ny);
ice_mask_max(mean(ice_mask,3)>0) = 1;

% To be conservative, fill missing months with maximum ice extent from
% preceding and following months
for ii = 1:size(missing_data,1)
    ind = find(year==missing_data(ii,1) & month==missing_data(ii,2));
    ice_mask(:,:,ind) = max(ice_mask(:,:,ind-1:ind+1),[],3);
end

% Repeat to fill back to back missing months
for ii = 1:size(missing_data,1)
    ind = find(year==missing_data(ii,1) & month==missing_data(ii,2));
    ice_mask(:,:,ind) = max(ice_mask(:,:,ind-1:ind+1),[],3);
end

% Load lat/lon and make into matrices
lon = ncread(fname,'lon');
lat = ncread(fname,'lat');
lon = repmat(lon,1,ny);
lat = repmat(lat',nx,1);

% save
fprintf('Saving to %s\n',fout)
save('-v7.3',fout,'year','month','lat','lon','ice_mask')
fprintf('Done! Total time: %.0f minutes\n',toc/60)