function oisst_an_cmip_future(rcp)
% ========================================
% Calculate future monthly SST anomalies based on historical
% OISSTv2 data plus mean change from CMIP5 ensemble
%
%   oisst_an_cmip_future(rcp)
%
% Input:
%   rcp: RCP scenario as numeric input (26, 45, or 85)
%
% Uses same methodology as oisst_an.m
%
% M. Jacox (2020)
% ========================================

% ========================================
% SET KEY PARAMETERS
% ========================================
clim_years = [1982 2011]; % Range of years to use for climatology
dirout = '~/Dropbox/MHW/Data'; % output directory

% ========================================
% LOAD SST DATA AND ICE MASK
% ========================================
fprintf('\nLoading OISST data\n')

% Load OISST
load ~/Dropbox/MHW/Data/oisst_an_1982-2019 sst year month lon lat lsm
lon_oisst = lon;
lat_oisst = lat;

% ========================================
% LOAD AND APPLY FUTURE SST CHANGE
% ========================================
fprintf('Applying CMIP5 SST change\n')

% Load CMIP5 output
f_cmip_his = sprintf('~/Dropbox/MHW/Data/sst.CMIP5.ENSMN.hist-rcp%d.mon.clim.1982-2011.nc',rcp);
f_cmip_fut = sprintf('~/Dropbox/MHW/Data/sst.CMIP5.ENSMN.rcp%d.mon.clim.2070-2099.nc',rcp);
lon_cmip = ncread(f_cmip_his,'lon');
lat_cmip = ncread(f_cmip_his,'lat');
sst_cmip_his = ncread(f_cmip_his,'sst');
sst_cmip_fut = ncread(f_cmip_fut,'sst');
dsst = sst_cmip_fut - sst_cmip_his;

% Interpolate monthly delta to OISST grid
% Use linear interpolation
% Fill NaNs along coast with nearest neighbor interpolation
for im = 1:12
    dsst_oisst_nn = interp2(lon_cmip',lat_cmip',dsst(:,:,im)',lon_oisst,lat_oisst,'nearest');
    dsst_oisst_cub = interp2(lon_cmip',lat_cmip',dsst(:,:,im)',lon_oisst,lat_oisst,'cub');
    ind = find(isnan(dsst_oisst_cub) & ~isnan(dsst_oisst_nn));
    dsst_oisst_cub(ind) = dsst_oisst_nn(ind);
    dsst_oisst(:,:,im) = dsst_oisst_cub;
end

% Add SST change
dsst3 = repmat(dsst_oisst,[1 1 length(1982:2019)]);
sst_future = sst + dsst3;
sst = sst_future;

clear sst_future dsst3

% ========================================
% CALCULATE ANOMALIES
% ========================================
fprintf('Calculating anomalies\n')

% Calculate climatology
for im = 1:12
    sst_clim(:,:,im) = mean(sst(:,:,month==im & year>=clim_years(1) & year<=clim_years(2)),3);
end

% Calculate anomaly
for ii = 1:size(sst,3)
    sst_an(:,:,ii) = sst(:,:,ii) - sst_clim(:,:,month(ii));
end

fprintf('Detrending anomalies (slow...)\n')
% Detrend anomaly (slow)
[nx,ny,~] = size(sst);
for ii = 1:nx
    for jj = 1:ny
        sst_an_dt(ii,jj,:) = detrend(squeeze(sst_an(ii,jj,:)));
    end
end

% Save
fname = sprintf('%s/oisst_cmip_future_an_rcp%d',dirout,rcp);
clearvars -except lat lon lsm month year sst* fname
fprintf('Saving SST anomalies to %s\n',fname)
save('-v7.3',fname)