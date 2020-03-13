function oisst_distance
% =====================================
% Create matrix of distances between points on the OISST grid
% For each latitude, a grid of 2879 x 720 distances is created
% The matrix is subset as necessary in thermal_displacement.m
%
% M. Jacox 2020
% =====================================

% Set output file
fout = '~/Dropbox/MHW/Data/oisst_distance';

% Load oisst lat/lon grid
f_grid = '~/Documents/Data/OISST/lsmask.oisst.v2.nc';
lon = double(ncread(f_grid,'lon'));
lat = double(ncread(f_grid,'lat'));

% Earth's radius in km
Re=6371;

% Get grid parameters for calculation
res = lon(2) - lon(1);
lats = min(lat):res:max(lat);
dlon = [min(lon)-max(lon):res:max(lon)-min(lon)]';
lat_mat = repmat(lats,length(dlon),1);
dlon_mat = repmat(dlon,1,length(lats));

% Loop through each latitude and calculate distance to all other points
tic
for ilat = 1:length(lats)
    % Calculate distance to all other points
    d(ilat,:,:) = real(Re*acos(sind(lats(ilat))*sind(lat_mat) + cosd(lats(ilat))*cosd(lat_mat).*cosd(dlon_mat)));

    % Periodically report status
    if rem(ilat,round(length(lats))/20)==0
        fprintf('%.0f%% done, %.0f min elapsed\n',100*ilat/length(lats),toc/60);
    end
end

% Save file
lat = lats;
d = real(single(d));
fprintf('\nSaving to %s\n\n',fout)
save('-v7.3',fout,'lat','dlon','d')
