function define_heatwaves(threshold,period,is_detrend)
% ============================================
% Identify heatwaves and calculate traditional metrics (intensity,
% duration)
%
%   define_heatwaves(threshold,period,is_detrend)
%
% Input:
%   threshold: SSTa percentile to use for heatwave definition (e.g., 90)
%   period: 'historical' or 'future'
%   is_detrend: 1 to detrend anomalies before calculating heatwaves
%
% M. Jacox 2020
% ============================================

% Output directory
dirout = '~/Dropbox/MHW/Data';

% ========================================
% DEFINE HEATWAVES
% ========================================
fprintf('Finding heatwaves\n')

% Years used for climatology to define thresholds
clim_years = [1982 2010];

% Load previously computed sst_anomalies
switch period
    case 'historical'
        f_an = sprintf('%s/oisst_an_1982-2019',dirout);
        if is_detrend == 1
            load(f_an,'sst_an_dt','year','lsm');
            sst_an = sst_an_dt;
            clear sst_an_dt
            fout = sprintf('%s/oisst_mhw_%dperc_1982-2019_detrended',dirout,threshold);
        else
            load(f_an,'sst_an','year','lsm')
            fout = sprintf('%s/oisst_mhw_%dperc_1982-2019',dirout,threshold);
        end
    case 'future'
        f_an = sprintf('%s/oisst_cmip_future_an',dirout);
        if is_detrend==1
            load(f_an,'sst_an_dt','year','lsm')
            sst_an = sst_an_dt;
            clear sst_an_dt
            fout = sprintf('%s/oisst_cmip_future_mhw_%dperc_detrended',dirout,threshold);
        else
            load(f_an,'sst_an','year','lsm')
            fout = sprintf('%s/oisst_cmip_future_mhw_%dperc',dirout,threshold);
        end
end

% Find heatwave thresholds for each point
sst_an_thr = prctile(sst_an(:,:,year>=clim_years(1) & year<=clim_years(2)),threshold,3);

% Define heatwave periods
[nx,ny,nt] = size(sst_an);
ishw = zeros(nx,ny,nt);
for ii = 1:nt
    tmp = zeros(nx,ny);
    tmp(sst_an(:,:,ii)>=sst_an_thr) = 1;
    ishw(:,:,ii) = tmp;
end

% ====================================================
% CALCULATE TRADITIONAL HEATWAVE CHARACTERISTICS
% ====================================================
fprintf('Calculating heatwave metrics\n')

% Calculate SST anomaly during heatwaves only
hw_ssta = sst_an.*ishw;
hw_ssta(hw_ssta==0) = nan;

% Identify heatwave starts
new_hw(:,:,1) = ishw(:,:,1);
new_hw(:,:,2:nt) = ishw(:,:,2:end) - ishw(:,:,1:end-1);
new_hw(new_hw<0) = 0;

% Identify heatwave ends
hw_end(:,:,1:nt-1) = ishw(:,:,1:end-1) - ishw(:,:,2:end);
hw_end(:,:,nt) = ishw(:,:,nt);
hw_end(hw_end<0) = 0;

% Calculate duration of heatwaves, store at index of heatwave start
hw_dur = nan(size(new_hw));
for ii = 1:nx
    for jj = 1:ny
        ind1 = find(new_hw(ii,jj,:)==1);
        ind2 = find(hw_end(ii,jj,:)==1);
        hw_dur(ii,jj,ind1) = ind2-ind1+1;
    end
end

% Save
clearvars -except *hw* lat lon lsm year month nx ny nt sst_an_thr threshold fout
fprintf('Saving heatwave info to %s\n',fout)
save('-v7.3',fout)