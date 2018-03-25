%% display the topography to check the location of the cluster
% input 
isDiff = input('Is this topograph for differences between Normal and Scramble?  1 (yes) 0(no)');
% load the data for topography
[fileNames, saveDir] = uigetfile('*.mat', 'Please choose the ''.mat'' file contains the raw mean (topo) data for topography.');
load([saveDir,fileNames]); % load the raw data

numLabels = size(table_TopoData,2);
numPotential = size(table_TopoData,1);

%% show the figure (loop)
% iPotential = [];
% iLabel = [];
% while isempty(iPotential)
%     iPotential = input('Please enter the potential number for the topography (P1: 1; N1: 2):');
% end
% while isempty(iLabel)
%     iLabel = input('Please enter the label number for the topography:');
% end

for iPotential = 1:numPotential
    for iLabel = 1:numLabels
        
        % Name of the figure
        namePart_Potential = table_TopoData.Properties.RowNames{iPotential,1};
        namePart_Label = table_TopoData.Properties.VariableNames{1,iLabel};
        figureName = [namePart_Potential, '-', namePart_Label];
        fileName = [expFolder, '-',figureName];
        
        % get the data for this potential and this label
        topoData = table_TopoData{iPotential,iLabel};
        
        if isDiff == 1
            if strcmp(namePart_Label(1), 'N')
                scramLabel = ['S', namePart_Label(2:3)];
                topoData_Scra = table_TopoData{iPotential,scramLabel};
                topoData = topoData - topoData_Scra;
                figureName = [figureName, '-NS'];
            end
        end
        
        topoFig = figure('Name',figureName);
        topoplot(topoData, ALLEEG(1).chanlocs,...  % ALLEEG(1).chanlocs, chanLocations
            'maplimits', [-5 5]);   % set the maximum and minimum value for all the value
%             'electrodes', 'labels'); %             'electrodes', 'labels'... % show the name of the labels on their locations

        colorbar; % show the color bar
        title(['\fontsize{20}', figureName]);
        % topoFig.Color = 'none';  % set the background color as transparent.
        topoFig.Position = [200, 300, 900, 750]; % resize the window for this figure
%         set(gcf, 'Position', [200, 200, 900, 750]) 
        
        % print the figure as pdf file
        figurePDFName = [saveDir, fileName];
        print(figurePDFName, '-dpdf');
    end
end


%% show the figure (one by one)
% iPotential = [];
% iLabel = [];
% while isempty(iPotential)
%     iPotential = input('Please enter the potential number for the topography (P1: 1; N1: 2):');
% end
% while isempty(iLabel)
%     iLabel = input('Please enter the label number for the topography:');
% end
% 
% % Name of the figure
% namePart1 = table_TopoData.Properties.RowNames{iPotential,1};
% namePart2 = table_TopoData.Properties.VariableNames{1,iLabel};
% figureName = [expFolder, '-', namePart1, '-', namePart2];
% 
% % get the data for this potential and this label
% topoData = table_TopoData{iPotential,iLabel};
% 
% topoFig = figure('Name',figureName);
% topoplot_EEGlab(topoData, ALLEEG(1).chanlocs,...  % ALLEEG(1).chanlocs, chanLocations
%     'maplimits', [-4 5],...   % set the maximum and minimum value for all the value
%     'electrodes', 'labels'... % show the name of the labels on their locations
%     ); 
% colorbar; % show the color bar
% title(['\fontsize{20}', figureName]);
% % topoFig.Color = 'none';  % set the background color as transparent.
% set(gcf, 'Position', [200, 200, 900, 750]) % resize the window for this figure
% 
% % print the figure as pdf file
% figurePDFName = [saveDir, figureName]; 
% print(figurePDFName, '-dpdf');