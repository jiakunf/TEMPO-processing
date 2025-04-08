
clear; 
close all;
warning on;
if(isempty(gcp('nocreate'))), parpool('Threads'); end 

diary(fullfile("P:\GEVI_Wave\Logs", ...
        strcat(string(datetime('now','Format','yyyyMMddHHmmss')),'_',mfilename(),'.log')));
%%

% basefolder_search = "P:\GEVI_Wave\Preprocessed\"; %"O:\michelle\VoltageDataBackup\GEVI_Wave\Raw\"; ; %"\\VoltageRaw\DCIMG\GEVI_Wave\Raw\"; 
% files = dir(fullfile(basefolder_search, "\Visual\m88*\**\meas*")); %dir(basefolder_raw + "Visual\m40\20210824\meas00\");
% recording_names = arrayfun(@(f) string(fullfile(f.folder, f.name)), files);
% recording_names = erase(recording_names, basefolder_search);

recording_names =  rw.readlines("N:\GEVI_Wave\filelists\filelis_anesthesia_transition_asap3.txt");
%%

basefolder_preprocessed = "P:\GEVI_Wave\Preprocessed\";
basefolder_processing = "T:\GEVI_Wave\Preprocessed\";
basefolder_output = "N:\GEVI_Wave\Analysis\";    
%%

skip_if_final_exists = false;

mouse_state = "transition";% "awake"; %"anesthesia" "transition"

crosstalk_matrix =  [[1, 0]; [0.07, 1]]; %[[1, 0]; [0.095, 1]]; %
% crosstalk_matrix =  [[1, 0]; [0.07, 1]]; %[[1, 0]; [0.095, 1]]; %
% for newer ASAP3 but 0.07 seems to work much better; 
% 0.1 for older ASAP2s with different filters 
% 0.095 for very old ace recordings seems good - based on m14 visual v1
% not sure this is correct, but it works for ASAP3 recordings

frame_range = [50, inf];

postfix_in1 = "cG_bin8_mc";
postfix_in2 = "cR_bin8_mc_reg";

%%

MEs = {};
for i_f = 1:length(recording_names)
    %%
    recording_name = recording_names(i_f);
    disp(string(i_f)+"/"+string(length(recording_names))+": "+recording_name);
    try
        pipeline_unmixing
    catch ME
        MEs{length(MEs)+1} = {recording_name, ME};
        warning(recording_name);
        warning(ME.message);
    end   
end
