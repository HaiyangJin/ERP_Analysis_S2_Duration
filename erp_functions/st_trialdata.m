function  allTrialEpoch = st_trialdata(EEG, channels, onsetEvent, respEvent, blockEvent)
% EEG: from eeglab
% channels: which channels would you like to output (double or cell)
% onsetEvent(cell): event of the onsets
% respEvent(cell): event of the reponses
% blockEvent(cell): events of the blocks
% isacc(logical): do you include accuracy data?

% Only works for individual EEG dataset (not study)

%% Default values
if nargin < 1
    error('Not enough inputs for eeg_trialdata!');
end
if nargin < 2 || isempty(channels)
    channels = 1:EEG.nbchan;
else
    channels = channame(channels); % covert anything to cell
    channels = sort(cellfun(@(x) str2double(x(2:end)), channels)); % convert cell to numbers
end
if nargin < 3 || isempty(onsetEvent) || isempty(respEvent) || isempty(blockEvent)
    events = unique({EEG.urevent.type});
end
if nargin < 3
    onsetEvent = events(cellfun(@(x) strcmp(x(end), '+'), events));
end
if nargin < 4
    respEvent = events(cellfun(@(x) strcmp(x(1:2), 'RE'), events));
end
if nargin < 5
    blockEvent = events(cellfun(@(x) strcmp(x(1:3), 'blo'), events));
end

% check if there is RT (latnecy) information for the events
isResp = logical(sum(ismember(respEvent, {EEG.event.type})));

% check if there is block information for the events
isBlock = logical(sum(ismember(blockEvent, {EEG.event.type})));


%% get information from EEG
nTrial = EEG.trials;
lagFrame = 1000 / EEG.srate;
varNames = xconverter(EEG.xmin * 1000 : lagFrame : EEG.xmax * 1000);

%% get the information about each trial
if isResp
    latency = eeg_getepochevent(EEG, respEvent,[],'latency');  % the latency of the response events
else
    warning('Resposne data are not available.');
end

% Get the original event number
urevent = eeg_getepochevent(EEG, onsetEvent,[],'urevent');  % remaining epochs
urTrialInfo = st_urtrialinfo(EEG, onsetEvent, respEvent, blockEvent);  % get the original information about each trial

% IV
allChannel = {EEG.urchanlocs.labels}';
Channel = allChannel(channels);
nRow = length(Channel);

trialEpochTableIV = table;
trialEpochTableDV = table;

for iEpoch = 1:nTrial
    
    % DV
    % data for this trial
    thisTrialData = EEG.data(channels,:,iEpoch);
    
    % IV
    thisUrevent = urevent(iEpoch);
    theEvents = EEG.epoch(iEpoch).eventtype;
    isOnset = ismember(theEvents, onsetEvent);
    if sum(isOnset) > 1
        warning(['There are more than one onset events in the epoch %d!\n'...
            'filename: %s'], iEpoch, EEG.setname);
    end
    Event = repmat(theEvents(isOnset), nRow, 1);
    Urevent = repmat(thisUrevent, nRow, 1);
    
    thisUrTrialInfo = urTrialInfo(ismember(urTrialInfo.Urevent, thisUrevent), :);
    
    TrialNumber = repmat(thisUrTrialInfo{1, 'TrialNumber'}, nRow, 1);
    
    isBlockTemp = ismember(theEvents, blockEvent);
    if sum(isBlockTemp) == 0 && ~strcmp(EEG.setname(2), '4')
        warning(['There is no block event for the epoch %d? \n'...
            'filename: %s'], iEpoch, EEG.setname);
    end
    if isBlock && any(isBlockTemp)
        blockStr = theEvents{isBlockTemp};
        Block = repmat(regexp(blockStr, '\d*', 'match'), nRow, 1);
    else
        Block = repmat({''}, nRow, 1);
    end
        
    if isResp
        isRespHere = ismember(theEvents, respEvent);
        if any(isRespHere) % Response
            respStr = theEvents{isRespHere};
            Response = repmat(regexp(respStr, '\d*', 'match'), nRow, 1);  % only get the numbers
            RT = repmat(latency(1, iEpoch), nRow, 1);
        else
            Response = repmat({''}, nRow, 1);
            RT = NaN(nRow, 1);
        end
        urResponse = repmat(thisUrTrialInfo{1, 'urResponse'}, nRow, 1);
        urRT = repmat(thisUrTrialInfo{1, 'urRT'}, nRow, 1);
    end
    
    % rejected trials by pop_eegthresh and pop_jointprob in EEGlab_120
    if ~isempty(EEG.reject.rejthresh)
        Rejthresh = repmat(EEG.reject.rejthresh(iEpoch), nRow, 1);
    else
        Rejthresh = zeros(nRow, 1);
    end
    if ~isempty(EEG.reject.rejjp)
        Rejjp = repmat(EEG.reject.rejjp(iEpoch), nRow, 1);
    else
        Rejjp = zeros(nRow, 1);
    end
    
    Reject = repmat(Rejthresh(1) || Rejjp(1), nRow, 1);
    
    thisIVTable = table(Channel, Event, Urevent, TrialNumber, Block, ...
        Response, urResponse, RT, urRT, Reject, Rejthresh, Rejjp);
    thisDVTable = array2table(thisTrialData, 'VariableNames', varNames);
    
    trialEpochTableIV = vertcat(trialEpochTableIV, thisIVTable); %#ok<AGROW>
    trialEpochTableDV = vertcat(trialEpochTableDV, thisDVTable); %#ok<AGROW>
end

% save the participant code
trialEpochTableIV.SubjCode = repmat({EEG.setname(1:4)}, size(trialEpochTableIV, 1), 1);

allTrialEpoch = horzcat(trialEpochTableIV, trialEpochTableDV);


end
