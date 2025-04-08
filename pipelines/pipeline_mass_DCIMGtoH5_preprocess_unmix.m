
clear; 
close all;
warning on;
if(isempty(gcp('nocreate'))), parpool('Threads'); end 

diary(fullfile("P:\GEVI_Wave\Logs", ...
        strcat(string(datetime('now','Format','yyyyMMddHHmmss')),'_',mfilename(),'.log')));
%%

basefolder_search = "R:\GEVI_Wave\Raw\"; 

files = dir(fullfile(basefolder_search, "\Spontaneous\mv0106\20250320\meas*")); %dir(basefolder_raw + "Visual\m40\20210824\meas00\");m**
recording_names = arrayfun(@(f) string(fullfile(f.folder, f.name)), files);
recording_names = erase(recording_names, basefolder_search);

% recording_names = ...[rw.readlines("N:\GEVI_Wave\filelists\filelist_michelle_unprocessed20240715.txt")]; 
%%

basefolder_raw = "R:\GEVI_Wave\Raw\"; %"\\VoltageRaw\DCIMG\GEVI_Wave\Raw\"; %"R:\GEVI_Wave\Raw\";% "M:\Raw Data Files\Raw\"; %%
basefolder_converted = "S:\GEVI_Wave\Preprocessed\"; %"S:\GEVI_Wave\Preprocessed\";
basefolder_processing = "T:\GEVI_Wave\Preprocessed\";
basefolder_preprocessed = "P:\GEVI_Wave\Preprocessed\"; %"P:\GEVI_Wave\Preprocessed\";
basefolder_analysis = "N:\GEVI_Wave\Analysis\";

skip_if_final_exists = true;

channels = ["G","R"];

binning = 8;
maxRAM = 0.1;
unaccounted_hardware_binning = 1; %For old recordings, hardware binning is not accounted for.

shifts0 = [0,0]; %[20,0]; % pix, between R and G channel due to cameras misalignment

mouse_state = "awake";% "awake"; %"anesthesia" %"transition";
crosstalk_matrix =  [[1, 0]; [0.07, 1]]; %[[1, 0]; [0.095, 1]]; %
frame_range = [50, inf];
%%

MEs_conv = {};
for i_f = 1:length(recording_names)
    %%
    
    recording_name = recording_names(i_f);
    
    disp(string(i_f)+"/"+string(length(recording_names))+": "+recording_name);
    error_state = false;
    %%
    
    try
        %%
        
        channels = ["G","R"];
%         skip_if_final_exists = true;
        pipeline_DCIMGtoH5
        %%
    catch ME
        MEs_conv{length(MEs_conv)+1} = ME;
        warning(recording_name);
        warning(getReport(ME));
    end   
    
    try
        %%
        
        basefolder_output = basefolder_preprocessed; 
        postfix_in1 = "cG_bin"+string(binning);
        postfix_in2 = "cR_bin"+string(binning);
        pipeline_preprocessing_2xmoco
        %%
    catch ME
        MEs_conv{length(MEs_conv)+1} = ME;
        warning(recording_name);
        warning(getReport(ME));
    end   

    try
        %%
        
        basefolder_output = basefolder_analysis;  
        postfix_in1 = "cG_bin"+string(binning)+"*_mc";
        postfix_in2 = "cR_bin"+string(binning)+"*_mc_reg";
%         skip_if_final_exists = false;
        pipeline_unmixing
        %%  
    catch ME
        MEs_conv{length(MEs_conv)+1} = ME;
        warning(recording_name);
        warning(getReport(ME));
    end 
end
%%

diary off;