
clear; 
close all;
if(isempty(gcp('nocreate'))), parpool('Threads'); end 

diary(fullfile("P:\GEVI_Wave\Logs", ...
        strcat(string(datetime('now','Format','yyyyMMddHHmmss')),'_',mfilename(),'.log')));
%%

files = dir("R:\GEVI_Wave\Raw\Visual\m88*\*\meas*");
recording_names = arrayfun(@(f) string(fullfile(f.folder, f.name)), files);
recording_names = erase(recording_names, "R:\GEVI_Wave\Raw\");

% recording_names = ["Spontaneous\mDLRKlMORcre001\20240912\meas00", ...
%                    "Spontaneous\mRArchLKl001\20240912\meas00"];
%%

channels = ["G","R"];

basefolder_raw =  "R:\GEVI_Wave\Raw\";% 
basefolder_converted = "S:\GEVI_Wave\Preprocessed\";
basefolder_processing = "T:\GEVI_Wave\Preprocessed\";
basefolder_output = "P:\GEVI_Wave\Preprocessed\";

binning = 8;
maxRAM = 0.1;
unaccounted_hardware_binning = 1; %For old recordings, hardware binning is not accounted for.

shifts0 = [0,0];
%%

MEs_conv = {};
for i_f = 1:length(recording_names)
    recording_name = recording_names(i_f);
    disp(string(i_f)+"/"+string(length(recording_names))+": "+recording_name);
    try
        pipeline_DCIMGtoH5
    catch ME
        MEs_conv{length(MEs_conv)+1} = ME;
        warning(recording_name);
        warning(ME.message);
    end   
end
%%

postfix_in1 = "cG_bin8";
postfix_in2 = "cR_bin8";

skip_if_final_exists  = true;

MEs_pp = {};
for i_f = 1:length(recording_names)

    recording_name = recording_names(i_f);
    disp(string(i_f)+"/"+string(length(recording_names))+": "+recording_name);

    try 
        pipeline_preprocessing_2xmoco
    catch ME
        MEs_pp{length(MEs_pp)+1} = {recording_name, ME};
        warning(recording_name);
        warning(ME.message);
    end
end
%%


    