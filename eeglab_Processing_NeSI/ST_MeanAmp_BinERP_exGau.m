%% Preparation for cluster 
addpath(genpath('Common_Functions'));
Mahuika;

ID = getenv('SLURM_ARRAY_TASK_ID'); 
% ID should be 201-216,301-316,401-408  21-24,31-34,41-42

eeglab;

% the study folder
expCode = ['20' ID(1)];
partCode = ID(end);

parameters.isCluster = 1;
parameters.isgwindow = 1;
parameters.isDenoise = 0;
parameters.isColorbar = 0;
parameters.plotWindow = [-200 996];

saveAmpData = 1;
saveBinEpoch = 1;
isDistAna = 0;
toSaveFigure = 0;


%% Conduct the single trial analysis
st_analysis(expCode, partCode, parameters, saveAmpData, saveBinEpoch, isDistAna, toSaveFigure);