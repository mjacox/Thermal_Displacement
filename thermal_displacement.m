function thermal_displacement(threshold,period,is_detrend,ilims,jlims)
% =======================================================
% Calculate horizontal displacement of surface isotherms during
% marine heatwaves
%
%   thermal_displacement(threshold,period,is_detrend,ilims,jlims)
%
% Input:
%   threshold: SSTa percentile to use for heatwave definition (e.g., 90)
%   period: 'historical' or 'future'
%   is_detrend: 1 to use detrended SST anomalies
%   ilims: longitude indices to calculate. Full grid is [1 1440]
%   jlims: latitude indices to calculate. Full grid is [1 720]
%
% Calculating thermal displacements is slow
% Large areas will take a long time to analyze
% =======================================================

% ====================================================
% CALCULATE THERMAL DISPLACEMENT
% ====================================================

% Data directory
dir = '~/Dropbox/MHW/Data';

% Set maximum displacement (to speed up code)
td_max = 3000; % km

% Load previously calculated SST and heatwave data
fprintf('Loading SST data and heatwave metrics\n')
switch period
    case 'historical'
        f_an = sprintf('%s/oisst_an_1982-2019',dir);
        if is_detrend == 1
            load(f_an,'sst','sst_an_dt','lat','lon','year','month')
            sst_an = sst_an_dt;
            clear sst_an_dt
            f_hw = sprintf('%s/oisst_mhw_%dperc_1982-2019_detrended',dir,threshold);
            fout = sprintf('%s/thermal_displacement_%dperc_detrended_%d-%d_%d-%d.mat',dir,threshold,ilims(1),ilims(2),jlims(1),jlims(2));
        else
            load(f_an,'sst','sst_an','lat','lon','year','month')
            f_hw = sprintf('%s/oisst_mhw_%dperc_1982-2019',dir,threshold);
            fout = sprintf('%s/thermal_displacement_%dperc_%d-%d_%d-%d.mat',dir,threshold,ilims(1),ilims(2),jlims(1),jlims(2));
        end
    case 'future'
        f_an = sprintf('%s/oisst_cmip_future_an',dir);
        if is_detrend == 1
            load(f_an,'sst','sst_an_dt','lat','lon','year','month')
            sst_an = sst_an_dt;
            clear sst_an_dt
            f_hw = sprintf('%s/oisst_cmip_future_mhw_%dperc_detrended',dir,threshold);
            fout = sprintf('%s/thermal_displacement_future_%dperc_detrended_%d-%d_%d-%d.mat',dir,threshold,ilims(1),ilims(2),jlims(1),jlims(2));
        else
            load(f_an,'sst','sst_an','lat','lon','year','month')
            f_hw = sprintf('%s/oisst_cmip_future_mhw_%dperc',dir,threshold);
            fout = sprintf('%s/thermal_displacement_future_%dperc_%d-%d_%d-%d.mat',dir,threshold,ilims(1),ilims(2),jlims(1),jlims(2));
        end
end
load(f_hw,'ishw')
[nx,ny,nt] = size(ishw);

% Load oisst grid distances
load(sprintf('%s/oisst_distance',dir),'d')

% Load oisst masks
load(sprintf('%s/oisst_masks',dir),'mask')

% Create placeholders
td = nan(nx,ny,nt);
td_ind = nan(nx,ny,nt);
td_fail = nan(nx,ny,nt);
d_nan = nan(nx,ny);

% Ocean points to be calculated
mask_sub = mask(ilims(1):ilims(2),jlims(1):jlims(2));
n_ocean = numel(find(isnan(mask_sub) | mask_sub>3));

% Loop through each grid cell
fprintf('Heatwave threshold is %d%%\n',threshold);
fprintf('Calculating thermal displacements for %.0f-%.0f lon, %.0f-%.0f lat\n',lon(ilims(1),1),lon(ilims(2),1),lat(1,jlims(1)),lat(1,jlims(2)));
nn = 1;
issaved = 0;
tic
for ii = ilims(1):ilims(2)
    for jj = jlims(1):jlims(2)

        if isnan(mask(ii,jj)) || mask(ii,jj) > 3
            
            % Extract grid distances for this lat/lon
            d_lat = squeeze(d(jj,end-nx-ii+2:end-ii+1,:));

            % Apply masks for special cases
            d_lat = apply_oisst_masks(ii,jj,d_lat,mask,lat,lon);

            % Loop through heatwave events and find thermal displacement
            ind = find(ishw(ii,jj,:)==1);
            for it = 1:length(ind)
                sst_norm = squeeze(sst(ii,jj,ind(it)) - sst_an(ii,jj,ind(it)));
                d_tmp = d_lat;
                d_tmp(isnan(sst(:,:,ind(it))) | sst(:,:,ind(it))>sst_norm | d_lat>td_max) = nan;
                if numel(find(~isnan(d_tmp)))==0
                    td_fail(ii,jj,ind(it)) = 1;
                    td(ii,jj,ind(it)) = nan;
                    td_ind(ii,jj,ind(it)) = nan;
                else
                    [td(ii,jj,ind(it)),td_ind(ii,jj,ind(it))] = nanmin(d_tmp(:));
                end
            end

            % Report status
            if rem(nn,500) == 0
                fprintf('%.1f%% done, %.0f min elapsed, %.0f min remaining\n',100*nn/n_ocean,toc/60,(toc/60/nn)*(n_ocean-nn))
            end
            
            nn = nn+1;

        end
    end

    % Save periodically (every 20 rows of longitude)
    if rem(ii,20)==0 && ii~=ilims(1) && ii~=ilims(2)
        if issaved == 1;
            fname_old = fname_tmp;
        end
        switch period
            case 'historical'
                if is_detrend == 1
                    fname_tmp = sprintf('~/Dropbox/MHW/Data/thermal_displacement_%dperc_detrended_%d-%d_%d-%d.mat',threshold,ilims(1),ii,jlims(1),jlims(2));
                else
                    fname_tmp = sprintf('~/Dropbox/MHW/Data/thermal_displacement_%dperc_%d-%d_%d-%d.mat',threshold,ilims(1),ii,jlims(1),jlims(2));
                end
            case 'future'
                if is_detrend == 1
                    fname_tmp = sprintf('~/Dropbox/MHW/Data/thermal_displacement_future_%dperc_detrended_%d-%d_%d-%d.mat',threshold,ilims(1),ii,jlims(1),jlims(2));
                else
                    fname_tmp = sprintf('~/Dropbox/MHW/Data/thermal_displacement_future_%dperc_%d-%d_%d-%d.mat',threshold,ilims(1),ii,jlims(1),jlims(2));
                end
        end
        fprintf('Saving partial file to %s\n',fname_tmp)
        save('-v7.3',fname_tmp,'lon','lat','year','month','td','td_ind','td_fail')

        % Remove previous file
        if issaved == 1
            cmd = sprintf('system(''rm -f %s'');',fname_old);
            eval(cmd);
        end
        issaved = 1;

    end
end

% Save
fprintf('Done! Saving to %s\n',fout)
save('-v7.3',fout,'lon','lat','year','month','td','td_ind','td_fail')

% Remove previous file
if issaved == 1
    cmd = sprintf('system(''rm -f %s'');',fname_tmp);
    eval(cmd);
end