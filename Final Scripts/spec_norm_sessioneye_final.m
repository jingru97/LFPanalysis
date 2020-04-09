

% This script calls functions rplparallel and rpllfp, and generates
% (1)spectrogram plot, and power spectrum across different channels for a
% specific sessioneye dataset

% (2)Compute the vmlfp data normalised to the sessioneyes data and
% generate spectrogram plot and power spectrum

%Spectrgram parameter: [window, overlap] = [500,450]
%normalisation window to 0 to 2000

userfol='/Users/jingru';

%get list of days 
cd /Volumes/Hippocampus/Data/picasso-misc

dateFolder=[dir('201807*');dir('201808*'); dir('201809*');dir('201810*');dir('2018011*') ];
dateFolder={dateFolder([dateFolder.isdir]).name};


for date = dateFolder
   % date= dateFolder(d);
   % date= char(date);
    
    
    for nav_session=1 %change this value to 1:3 for 2017 sessions
        navsession= strcat('session0',string(nav_session),'');
    
        sessioneye='sessioneye';
        date=char(date);
        cd(char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/')))
        mkdir(date)
        cd(char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/',date)))
        mkdir(navsession)

        for arrayno=1:4
            % Initialises array name
            array=strcat('array0',string(arrayno),'');

            % Runs the conglomerated function for each channel in each array;
            % switch for speed
            switch arrayno
                case 1 % array 1
                    for channelno=1:32
                        channel=channelname(channelno);
                        %saves the individual plots for each channel
                        [mrawspecdat(channelno).data,mspecdat(channelno).data,mvlspecdat(channelno).data]=combfun(navsession,channel,array,sessioneye,date,userfol);
                    end

                case 2 % array 2
                    for channelno=33:64
                        channel=channelname(channelno);
                        %saves the individual plots for each channel
                        [mrawspecdat(channelno).data,mspecdat(channelno).data,mvlspecdat(channelno).data]=combfun(navsession,channel,array,sessioneye,date,userfol);
                       
                    end

                case 3 % array 3
                    for channelno=65:96
                        channel=channelname(channelno);
                        %saves the individual plots for each channel
                        [mrawspecdat(channelno).data,mspecdat(channelno).data,mvlspecdat(channelno).data]=combfun(navsession, channel,array,sessioneye,date,userfol);
                    end

                case 4 % array 4
                    for channelno=97:128
                        channel=channelname(channelno);
                        %saves the individual plots for each channel
                        [mrawspecdat(channelno).data,mspecdat(channelno).data,mvlspecdat(channelno).data]=combfun(navsession, channel,array,sessioneye,date,userfol);
                    end
            end
            % save(char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/',date,'/',navsession,'/',date,'_seseye_data.mat')),'mrawspecdat','mspecdat','mvlspecdat')
        end
            save(char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/',date,'/',navsession,'/',date,'_seseye_data.mat')),'mrawspecdat','mspecdat','mvlspecdat')
    end 

end


    
% -------------------------------------------------------------------------

function [channel] = channelname(channelno)

% Initialises channel name
if numel(num2str(channelno))==1
    channel=strcat('channel00',string(channelno),'');
elseif numel(num2str(channelno))==2
    channel=strcat('channel0',string(channelno),'');
elseif numel(num2str(channelno))==3
    channel=strcat('channel',string(channelno),'');
end

end

function [mrawspec,mspec,mvlspec] = combfun(navsession,channel,array,sessioneye,date,userfol)

% Initialises directory name
folder=strcat('/Volumes/Hippocampus/Data/picasso-misc/',date,'/',sessioneye,'/',array,'/',channel);

session_folder=strcat('/Volumes/Hippocampus/Data/picasso-misc/',date,'/', navsession, '/',array,'/',channel);

if exist(char(session_folder), 'dir')==7 % Check that the folder exists
    
    % define parameters
    c1=-4; c2=4;
    t1=0.25; t2=2;
    t3=-0.75; t4=10;
    
    % creates a folder for the channel
    cd(char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/', date,'/' ,navsession)))
    mkdir(channel)
    
    % Generate the lfp time-domain data (Frequency 0-150Hz)
    cd(char(folder))
    rp = rplparallel('auto');
    lfp = rpllfp('auto');
    
    % ===============================================================
    % plot the signal average
%     signalaverage(lfp, [2 10], [-25 25])
%     saveas(gcf,strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/',date,savefolder,channel,'/signalaverage_',date,'_',channel,'.png'))
%     close
    
    % ===============================================================
    % plot the raw spectrogram for eyesession
    
    % Voltage data should be retrieved for each trial with 200ms before the cue time (baseline data)
    T=1;
    
    for n = 1:length(rp.data.markers) % trial marker
        
        if rp.data.markers(n) == 6
        
        % Obtain trial index for the marker
        % Each datapoint increases by 0.0010s, starting from time index 0-
        % so each time stamp corresponds to index using the following formula:
        % index = time*1000+1
        
        % Trial for eye data will be from marker 6 to marker 32
        tIdx(1) = round(rp.data.timeStamps(n)*1000+1);
        tIdx(2) = round(rp.data.timeStamps(n+2)*1000+1);
        
        % Spectrogram data for the entire trial including a 1s pre-trial period
        idx = (tIdx(1):tIdx(2));
        data = lfp.data.analogData(idx);
        datam = mean(data);
        [~,spec(T).F,spec(T).T,spec(T).P]=spectrogram(data-datam,500,450,(0:50),1000,'yaxis');
        
        % Normalisation to Baseline Period:
        % This is the old methodology where the spectrogram data for each trial is normalised to a pre-specified baseline period within the trial
        % each trial is normalised to a baseline period then averaged
        
        % Spectrogram data for the normalisation period
        idx = (tIdx(1)-700:tIdx(1));
        data = lfp.data.analogData(idx);
        datam = mean(data);
        [~,~,~,P]=spectrogram(data-datam,500,450,(0:50),1000,'yaxis');
        
        % Normalisation parameters using the mean and stdev of the power
        % for the normalisation period
        Pmean=mean(P,2); %mean power density of each frequency bin
        Pstd=std(P,0,2); %standard deviation of each frequency bin
        
        spec(T).Pnorm=(spec(T).P-Pmean)./Pstd;
        
        T=T+1;
        
        end
        
    end
    
    % Creates a structure that averages the normalised data across all trials
    % without standardising the time bins (but limit the data to 1s only)
    
    for s=1:36 % limit the data from 0s to 2s only (average mean length of the eyesession trials)
        % initialise variables
        Pmatrix=[];
        for n=1:length(spec) % for each trial
            if s>size(spec(n).P,2) % skips the trials that have already ended
                continue
            else
                % append the PSD and spectrogram information to one big matrix
                Pmatrix(:,n)=spec(n).P(:,s);
                Pmatrixnorm(:,n)=spec(n).Pnorm(:,s);
            end
        end
        % Average the data from all trials together
        mrawspec.Pnorm(:,s)=mean(Pmatrix,2);
        mspec.Pnorm(:,s)=mean(Pmatrixnorm,2);
    end
    
    %Initialise the time and frequency data
    mrawspec.T=(t1:0.05:t2);
    mrawspec.F=spec.F;
    mspec.T=mrawspec.T;
    mspec.F=spec.F;

    % ===============================================================
    
    plotspec(mrawspec,t1,t2,1,50,c1,c2);
    % save the raw spectrogram plot
    saveas(gcf,char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/',date,'/',navsession,'/',channel,'/PSD_rawspec_',date,'_',channel,'.png')))
    close
    
    % compute and save normalised spectrogram plot
    plotspec(mspec,t1,t2,1,50,c1,c2);
    saveas(gcf,char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/',date,'/',navsession,'/',channel,'/norm_-500to-200_PSD_',date,'_',channel,'.png')))
    close
    
    % compute power spectrum
%     Pnorm=mean(mspec.Pnorm,2);
%     plot(mspec.F,Pnorm,'color','black','LineWidth',2)
%     axis([1 50 c1 c2]);
%     set(gca,'FontSize',15); xticks(0:5:50); yticks(c1:1:c2);
%     xlabel('Frequency (Hz)'); ylabel('Z-scored Power');
%     
%     % plot reference lines
%     hold on
%     line([2 2],[-100 100])
%     line([5 5],[-100 100])
%     line([6 6],[-100 100])
%     line([9 9],[-100 100])
%     line([0 50],[0 0],'LineStyle','--')
%     hold off
    
    % save power spectrum plot
%     saveas(gcf,char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/',date,'/',navsession,'/',channel,'/norm_-500to-200_PS_',date,'_',channel,'.png')))
%     close
    
    
    % ===============================================================
    % ===============================================================
    % ===============================================================
    % Computing vmlfp data normalised to the seseyes data
    
    cd(char(strcat('/Volumes/Hippocampus/Data/picasso-misc/',date,'/',navsession,'/',array,'/',channel)))
    vl = vmlfp('auto');
    
    % Normalisation parameters using the mean and stdev of the power
    % for the normalisation period
    Pmean=mean(mrawspec.Pnorm,2); %mean power density of each frequency bin
    Pstd=std(mrawspec.Pnorm,0,2); %standard deviation of each frequency bin
    
    % Spectrogram data for the entire trial including a 1s pre-trial period
    for n = 1:vl.data.numSets % trial number
        
        % Spectrogram data for the entire trial including a 1s pre-trial period
        tIdx = vl.data.trialIndices(n,:); % Obtain trial indexes
        idx = (tIdx(1)-(1000/1000*1000)):tIdx(3);
        data = vl.data.analogData(idx);
        datam = mean(data);
        [~,vlspec(n).F,vlspec(n).T,vlspec(n).P]=spectrogram(data-datam,500,450,(0:50),1000,'yaxis');
        
        % compute normalised spectrogram
        vlspec(n).Pnorm=(vlspec(n).P-Pmean)./Pstd;
        
    end
    
    % ===============================================================
    % Creates a structure that averages the normalised data across all trials
    % without standardising the time bins (but limit the data to 10s only)
    
    for s=1:216 % limit the data from -1.0s to 10s only (average mean length of the trials)
        Pmatrix=[];
        for n=1:vl.data.numSets % for each trial
            if s>size(vlspec(n).Pnorm,2) % skips the trials that have already ended
                continue
            else
                % append the PSD and spectrogram information to one big matrix
                Pmatrix(:,n)=vlspec(n).Pnorm(:,s);
            end
        end
        % Average the data from all trials together
        mvlspec.Pnorm(:,s)=mean(Pmatrix,2);
    end
    
    %Initialise the time and frequency data
    mvlspec.T=(t3:0.05:t4);
    mvlspec.F=spec.F;
    
    % save normalised spectrogram plot
    plotspec(mvlspec,t3,t4,1,50,c1,c2);
    saveas(gcf,char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research1/',date,'/',navsession,'/',channel,'/PSD_vlnormspec_',date,'_',channel,'.png')))
    close
    
   % power spectrum
    datafol = '/Users/jingru/Desktop/results/Hippocampal LFP Research1/';
    
    localpowerspectrum(mvlspec,1,50,c1,c2,datafol,date,navsession,channel);
    
    
else
    mrawspec.Pnorm=[]; mrawspec.F=[]; mrawspec.T=[];
    mspec.Pnorm=[]; mspec.F=[]; mspec.T=[];
    mvlspec.Pnorm=[]; mvlspec.F=[]; mvlspec.T=[];
end

end

function [Pnorm1, Pnorm2, Pnorm4, Pnorm5, Pnorm6] = localpowerspectrum(mspec,x1,x2,y1,y2,datafol,date,navsession,channel)


    %for plot1
    Pnorm1=mean(mspec.Pnorm(:,16:36),2); % Cue-onset (0-1)
    err1= std(mspec.Pnorm(:,16:36),0,2)/sqrt(20);
    

    Pnorm2=mean(mspec.Pnorm(:,36:56),2); % Pure movement (1-2)
    err2= std(mspec.Pnorm(:,36:56),0,2)/sqrt(20);

    Pnorm3=mean(mspec.Pnorm(:,1:16),2); % Pre-Cue (-1 to 0)
    err3= std(mspec.Pnorm(:,1:16),0,2)/sqrt(15);
    
   
    Pnorm4=mean(mspec.Pnorm(:,end-20:end),2); %1 second window towards end of session
    err4= std(mspec.Pnorm(:,end-20:end),0,2)/sqrt(20);

    %for plot2
    Pnorm5=mean(mspec.Pnorm(:,16:26),2); % 1st half of cue (0-0.5)
    err5= std(mspec.Pnorm(:,16:26),0,2)/sqrt(10);
    Pnorm6=mean(mspec.Pnorm(:,26:36),2); % 2nd half of cue(0.5-1)
    err6= std(mspec.Pnorm(:,26:36),0,2)/sqrt(10);


    figure('Position', get(0, 'Screensize'))
    
    
    errorbar(mspec.F, Pnorm2,err2)
    %plot(mspec.F,Pnorm2,'LineWidth',2)
    hold on
    errorbar(mspec.F, Pnorm1,err1)
    %plot(mspec.F,Pnorm1,'LineWidth',2)
    hold on
    errorbar(mspec.F, Pnorm3,err3)
    %plot(mspec.F,Pnorm3,'LineWidth',2)
    hold on
    errorbar(mspec.F, Pnorm4,err4)
    %plot(mspec.F,Pnorm4,'LineWidth',2)

    axis([x1 x2 y1 y2]);
    set(gca,'FontSize',15); xticks(0:5:x2); yticks(y1:(y2-y1)/5:y2);
    title(strcat('ZScored Power against Frequency Plot1 ',channel),'FontSize',20);
    ylabel('Z-scored Power');
    legend({'Pure Movement(1-2s)','Cue-onset(0-1s)','Pre-Cue(-1-0s)','End Trial 1s'})

    % plot reference lines
    hold on
    line([2 2],[-100 100]) 
    line([5 5],[-100 100])
    line([6 6],[-100 100])
    line([9 9],[-100 100])
    line([0 50],[0 0],'LineStyle','--')
    line([0 50],[3 3],'LineStyle','--')
    line([0 50],[-3 -3],'LineStyle','--')
    
    hold off
    legend({'Pure Movement(1-2s)','Cue-onset(0-1s)','Pre-Cue(-1-0s)','End Trial 1s'})

    saveas(gcf,char(strcat(datafol,date,'/',navsession,'/', channel,'/errorbarPlot1_',date,'_' ,channel, '.png')))
    close

    figure('Position', get(0, 'Screensize'))
    errorbar(mspec.F, Pnorm2,err2)
    %plot(mspec.F,Pnorm2,'LineWidth',2)
    hold on
    errorbar(mspec.F, Pnorm5,err5)
   % plot(mspec.F,Pnorm5,'LineWidth',2)
    hold on
    errorbar(mspec.F, Pnorm6,err6)
    %plot(mspec.F,Pnorm6,'LineWidth',2)

    axis([x1 x2 y1 y2]);
    set(gca,'FontSize',15); xticks(0:5:x2); yticks(y1:(y2-y1)/5:y2);
    title(strcat('ZScored Power against Frequency Plot2 ',channel),'FontSize',20);
    ylabel('Z-scored Power');
   

    % plot reference lines
    hold on
    line([2 2],[-100 100]) 
    line([5 5],[-100 100])
    line([6 6],[-100 100])
    line([9 9],[-100 100])
    line([0 50],[0 0],'LineStyle','--')
    line([0 50],[3 3],'LineStyle','--')
    line([0 50],[-3 -3],'LineStyle','--')
    hold off
    legend({'Pure Movement(1-2s)','1st half of cue (0-0.5s)','2nd half of cue (0.5-1s)'})
    
    saveas(gcf,char(strcat(datafol,date,'/',navsession,'/', channel,'/errorbarPlot2_',date,'_', channel, '.png')))
    close

    
end





