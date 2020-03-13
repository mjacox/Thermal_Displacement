function oisst_an
% ========================================
% Calculate historical monthly SST anomalies from OISSTv2
%
% M. Jacox (2020)
% ========================================

% ========================================
% SET KEY PARAMETERS
% ========================================
years = [1982 2019]; % Range of years to be analyzed
clim_years = [1982 2010]; % Range of years to use for climatology
dirout = '~/Dropbox/MHW/Data'; % output directory

% ========================================
% LOAD SST DATA AND ICE MASK
% ========================================
fprintf('\nLoading OISST data\n')

% Load OISST
load ~/Documents/Data/OISST/OISST_25km_monthly/OISST_25km_monthly_1982-2019 year month lat lon lsm sst

% Load ice mask
load ~/Documents/Data/OISST/OISST_25km_monthly/oisst_25km_monthly_ice_mask_1982-2019 ice_mask

% Constrain to specified years
ind = find(year>=years(1) & year<=years(2));
sst = sst(:,:,ind);
year = year(ind);
month = month(ind);
[nx,ny,nt] = size(sst);

% Treat some water bodies as land
lsm(lon>=267 & lon<285 & lat>=41 & lat<=50) = 1; % Great lakes
lsm(lon>=269.5 & lon<270.5 & lat>=30 & lat<=31) = 1; % Lake Ponchartrain

% Apply land mask
for ii = 1:nt
    tmp = sst(:,:,ii);
    tmp(lsm==1) = nan;
    sst(:,:,ii) = tmp;
end

% Apply ice mask
sst(ice_mask==1) = nan;

% ========================================
% CALCULATE ANOMALIES
% ========================================
fprintf('Calculating anomalies\n')

% Calculate climatology
for im = 1:12
    sst_clim(:,:,im) = mean(sst(:,:,month==im & year>=clim_years(1) & year<=clim_years(2)),3);
end

% Calculate anomaly
for ii = 1:nt
    sst_an(:,:,ii) = sst(:,:,ii) - sst_clim(:,:,month(ii));
end

% Detrend anomalies (slow)
fprintf('Detrending anomalies (slow...)\n')
sst_an_dt = nan(size(sst_an));
for ii = 1:nx
    for jj = 1:ny
        sst_an_dt(ii,jj,:) = detrend(squeeze(sst_an(ii,jj,:)));
    end
end

% ========================================
% SAVE
% ========================================
fname = sprintf('%s/oisst_an_%d-%d.mat',dirout,years(1),years(2));
clearvars -except lat lon lsm month year sst* fname
fprintf('Saving SST anomalies to %s\n',fname)
save('-v7.3',fname)
