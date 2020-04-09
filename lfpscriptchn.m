
% LFP script to run the functions vmlfp, lfpspec and lfpfig across different
% directories/ sessions

for sessionname=["20180430","20180427","20180426","20180424","20180419","20180416","20180412","20180410","20180406","20180404","20180402","20180328","20180322","20180314","20180226","20180221","20180201","20180125","20180123"]
    sessionno="session01";
    
    for array=1:4
        % Initialises array name
        arrayname=strcat("array0",string(array),"");
        
        % Runs the conglomerated function for each channel in each array;
        % switch for speed
        switch array
            case 1 % array 1
                for channel=1:32
                    %saves the variables and the individual plots for each channel
                    mspec=lfparray(arrayname,channel,sessionname,sessionno);
                    arrayspec(channel)=mspec;
                end
                lfpfigarray(arrayname,arrayspec,1:32,sessionname,sessionno);  %creates the combined array plot
                
            case 2 % array 2
                for channel=43
                    %saves the variables and the individual plots for each channel
                    mspec=lfparray(arrayname,channel,sessionname,sessionno);
                    arrayspec(channel)=mspec;
                end
                lfpfigarray(arrayname,arrayspec,33:64,sessionname,sessionno);  %creates the combined array plot
                
            case 3 % array 3
                for channel=65:96
                    %saves the variables and the individual plots for each channel
                    mspec=lfparray(arrayname,channel,sessionname,sessionno);
                    arrayspec(channel)=mspec;
                end
                lfpfigarray(arrayname,arrayspec,65:96,sessionname,sessionno);  %creates the combined array plot
                
            case 4 % array 4
                for channel=97:128
                    %saves the variables and the individual plots for each channel
                    mspec=lfparray(arrayname,channel,sessionname,sessionno);
                    arrayspec(channel)=mspec;
                end
                lfpfigarray(arrayname,arrayspec,97:128,sessionname,sessionno);  %creates the combined array plot
        end
    end
    
    save(strcat("/Volumes/Hippocampus/Data/picasso/",sessionname,"/",sessionno,"/arrayspec",""),"arrayspec") % saves the arrayspec data in the session folder
    chn43.(strcat("Date_",sessionname,""))=mspec;
end
% -------------------------------------------------------------------------

function [mspec] = lfparray(arrayname,channel,sessionname,sessionno)
% Initialises channel name
if numel(num2str(channel))==1
    channelname=strcat("channel00",string(channel),"");
elseif numel(num2str(channel))==2
    channelname=strcat("channel0",string(channel),"");
elseif numel(num2str(channel))==3
    channelname=strcat("channel",string(channel),"");
end

% Initialises directory name
folder=strcat("/Volumes/Hippocampus/Data/picasso/",sessionname,"/",sessionno,"/",arrayname,"/",channelname,"");

if exist(folder, "dir")==7 % Check that the folder exists
    % change directory to each channel
    cd(folder)
    
    % Runs and saves the vl, spec, and mspec variables in the
    % workspace
    vl = vmlfp("auto");
    [spec, mspec] = lfpspec(vl);
    
    if ~isempty(mspec.Pnorm)==1
        save(strcat(folder,"/lfpspec",""),"vl","spec","mspec")
        
        % Generates the spectrogram and CC plot and saves it for each
        % channel
        lfpfig(mspec,"mspec");
        sgtitle(strcat("chn00",string(channel),""));
        saveas(gcf,strcat(folder,"/lfpspec_",channelname,".png",""))
        close
    end
else
    mspec.Pnorm=[]; mspec.Snorm=[]; mspec.F=[]; mspec.T=[]; mspec.cc=[];
end
end

% -------------------------------------------------------------------------

function [] = lfpfigarray(arrayname,arrayspec,channelno,sessionname,sessionno)

folder=strcat("/Volumes/Hippocampus/Data/picasso/",sessionname,"/",sessionno,"/",arrayname,"");
if exist(folder, "dir")==7 % Check that the folder exists
    cd(folder);
    
    % plot the non-standardised spectrogram for all channels in an array
    figure("Position", get(0, "Screensize"))
    subplotno=1;
    for channel=channelno
        if ~isempty(arrayspec(channel).Pnorm)==1 % plots only for channels with data
            % Initialises subplot
            subplot(7,5,subplotno);
            
            % Generates subplot for spectrogram (averages without standardising the time scale)
            surf(arrayspec(channel).T,arrayspec(channel).F,arrayspec(channel).Pnorm,"EdgeColor","none");
            axis xy; axis([-0.5 inf 0 150]); colormap(jet); view(0,90); caxis([-3 3]);
            title(strcat("chn00",string(channel),""),"FontSize",6);
            set(gca,"FontSize",6);
        end
        subplotno=subplotno+1;
    end
    colorbar("Position", [0.915  0.11  0.015  0.8]);
    sgtitle(strcat("Normalised PSD averaged for all trials for ",arrayname,""),"FontSize",12);
    % Save the figure in the array folder
    saveas(gcf,strcat(folder,"/lfp_spec_",arrayname,".png",""))
    close
    
    % plot the non-standardised cc plot for all channels in an array
    figure("Position", get(0, "Screensize"))
    subplotno=1;
    for channel=channelno
        if ~isempty(arrayspec(channel).cc)==1 % plots only for channels with data
            % Initialises subplot
            subplot(6,6,subplotno);
            
            % Generates subplot for spectrogram (averages without standardising the time scale)
            heatmap(arrayspec(channel).F,flipud(arrayspec(channel).F),flipud(arrayspec(channel).cc),...
                "XLimits",{0,148.43750},"YLimits",{148.43750,0},...
                "XDisplayLabels",(round(arrayspec(channel).F)),"YDisplayLabels",(flipud(round(arrayspec(channel).F))),...
                "Colormap", jet,"ColorLimits",[-0.2,0.7],"ColorbarVisible","on",...
                "Title",strcat("chn00",string(channel),""),"FontSize",5);
        end
        subplotno=subplotno+1;
    end
    sgtitle(strcat("CC plot averaged for all trials for ",arrayname,""),"FontSize",12);
    % Save the figure in the array folder
    saveas(gcf,strcat(folder,"/lfp_cc_",arrayname,".png",""))
    close
end
end

