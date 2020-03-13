function oisst_monthly_average
% ======================================
% Make monthly averages of daily OISST data
%
% M. Jacox 2020
% ======================================

% ========================================
% SET PARAMETERS
% ========================================
years = [1982 2019]; % Years to average
dirin = '~/Documents/Data/OISST/OISST_25km_daily/sst';
dirout = '~/Documents/Data/OISST/OISST_25km_monthly';

% ========================================
% LOAD DATA AND COMPUTE MONTHLY MEANS
% ========================================
ii = 1; % Counter
for iy = years(1):years(2);
    
    % Update status
    fprintf('Loading %d\n',iy)
    
    % Load data
    fname = sprintf('%s/sst.day.mean.%d.nc',dirin,iy);
    time = ncread(fname,'time');
    sst = ncread(fname,'sst');
    
    % Find month
    [~,mm,~] = datevec(datenum([1800 1 1]) + time);
    
    % Monthly average
    for im = 1:max(mm)
        sst_mon(:,:,ii) = mean(sst(:,:,mm==im),3);
        year(ii) = iy;
        month(ii) = im;
        ii = ii + 1;
    end
end

% Load grid info
lat = ncread(fname,'lat');
lon = ncread(fname,'lon');

% Make lat/lon matrics
nx = length(lon);
ny = length(lat);
lat = repmat(lat',nx,1);
lon = repmat(lon,1,ny);

% Remove missing values
sst_mon(abs(sst_mon)>100) = nan;

% Load land/sea mask
% Change from land=0 sea=1 to land=1 sea=0
lsm = ncread('~/Documents/Data/OISST/lsmask.oisst.v2.nc','lsmask');
lsm = -lsm + 1;

% ========================================
% SAVE
% ========================================
fout = sprintf('%s/OISST_25km_monthly_%d-%d',dirout,years(1),years(2));
sst = sst_mon;
fprintf('Saving to %s\n',fout)
save('-v7.3',fout,'year','month','lat','lon','lsm','sst')