%This scripts generates the times series data from rpllfp.mat before filter
%and after applying bandpass/lowpass filter 

bandwidth= [1 5];
ylimits =[-15 15];
choice=2;  %1: plot signal averages as well as odd and even averages, for all channels
           %2: plot signal averages of all channels for time period [-1000
           %2000]


datafol = '/Users/jingru/Desktop/results/old/';
%figure;
%dateFolder=[dir('201807*');dir('201808*'); dir('201809*');dir('201810*');dir('2018011*') ];
dateFolder= [{'20181001'}];
%dateFolder={dateFolder([dateFolder.isdir]).name};


for date=dateFolder
    date=char(date);
    for session=1
        navsession= strcat('session0',string(session),'');                                                                   

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

                            try
                                session_folder=strcat('/Volumes/Hippocampus/Data/picasso-misc/',date,'/', navsession, '/',array,'/',channel);
                                cd (char(session_folder))
                                lfp = vmlfp('auto');

                                if choice ==1
                                    sigavg1(lfp, bandwidth,ylimits, navsession, datafol, date,channel);
                                else
                                    sigavg2(lfp, bandwidth, ylimits, navsession, datafol, date,channel);
                                end

                            catch
                                disp('skipped')
                            end

                        end

                    case 2 % array 2
                        for channelno=33:64
                            channel=channelname(channelno);
                             try
                                session_folder=strcat('/Volumes/Hippocampus/Data/picasso-misc/',date,'/', navsession, '/',array,'/',channel);
                                cd (char(session_folder))
                                lfp = vmlfp('auto');

                                if choice ==1
                                    sigavg1(lfp, bandwidth,ylimits, navsession, datafol, date,channel);
                                else
                                    sigavg2(lfp, bandwidth, ylimits, navsession, datafol, date,channel);
                                end

                            catch
                                disp('skipped')
                            end


                        end

                    case 3 % array 3
                        for channelno=65:96
                            channel=channelname(channelno);
                            %saves the individual plots for each channel
                                try
                                session_folder=strcat('/Volumes/Hippocampus/Data/picasso-misc/',date,'/', navsession, '/',array,'/',channel);
                                cd (char(session_folder))
                                lfp = vmlfp('auto');

                                if choice ==1
                                    sigavg1(lfp, bandwidth,ylimits, navsession, datafol, date,channel);
                                else
                                    sigavg2(lfp, bandwidth, ylimits, navsession, datafol, date,channel);
                                end

                            catch
                                disp('skipped')
                            end

                        end

                    case 4 % array 4
                        for channelno=97:128
                            channel=channelname(channelno);
                            %saves the individual plots for each channel
                           try
                                session_folder=strcat('/Volumes/Hippocampus/Data/picasso-misc/',date,'/', navsession, '/',array,'/',channel);
                                cd (char(session_folder))
                                lfp = vmlfp('auto');

                                if choice ==1
                                    sigavg1(lfp, bandwidth,ylimits, navsession, datafol, date,channel);
                                else
                                    sigavg2(lfp, bandwidth, ylimits, navsession, datafol, date,channel);
                                end

                            catch
                                disp('skipped')
                           end


                        end

                end

        end


    end
end    


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


function [] = sigavg1(lfp, bandwidth,ylimits, navsession, datafol, date,channel)

              
        signalaverage(lfp, bandwidth,ylimits)
        saveas(gcf,char(strcat(datafol,date, '/' ,navsession,'/', channel,'/signalaverage_',date,'_',navsession, '_', channel,'.png')))
        close

end 



function []= sigavg2(lfp, bandwidth,ylimits , navsession, datafol, date,channel)
        
    d = designfilt('bandpassiir','FilterOrder',10, ...
        'HalfPowerFrequency1', bandwidth(1),'HalfPowerFrequency2',bandwidth(2), ...
        'SampleRate',1000);


    epoch=[-1000 2000];
        for n=1:lfp.data.numSets
            tIdx = lfp.data.trialIndices(n,:); %Obtain trial indexes
            idx = (tIdx(1)+epoch(1)):(tIdx(1)+epoch(2)); %Retrieve the epoch numbers (sampling rate is 1000)
            data = lfp.data.analogData(idx); %retrieve data for the trial
            datam = mean(data);
            datamat(n,:) = data-datam; %save the demeaned data in a matrix
        end

       % dataodd=datamat(1:2:end,:);
       % oddaverage=mean(dataodd);
       % dataeven=datamat(2:2:end,:);
       % evenaverage=mean(dataeven);
        totalaverage=mean(datamat);
       % subtractaverage=(oddaverage-evenaverage)/2;


        figure;
        plot((epoch(1):epoch(2)),filter(d,totalaverage),'.-') %total average
        ylim(ylimits)
        % Plot lines to mark the zero crossing
        hold on
        line([epoch(1) epoch(2)],[0 0],[10 10; 10 10],'Color','k');
        line([0 0],[-100 100])
        line([1000 1000],[-100 100])
        line([2000 2000],[-100 100])

        hold off

        title(channel)
        ylabel('Signal(uV)')
        xlabel('Time(ms)')
        saveas(gcf,char(strcat(datafol,date, '/seseyev6_1/', channel,'/signalaverage[1 5]_',date,'_',navsession, '_', channel,'.png')))
        close
        
%         figure;
%         plot((epoch(1):epoch(2)),totalaverage,'.-') %total average
%         ylim(ylimits)
%         % Plot lines to mark the zero crossing
%         hold on
%         line([epoch(1) epoch(2)],[0 0],[10 10; 10 10],'Color','k');
%         line([0 0],[-100 100])
%         line([1000 1000],[-100 100])
%         line([2000 2000],[-100 100])
% 
%         hold off
% 
%         title(channel)
%         ylabel('Signal(uV)')
%         xlabel('Time(ms)')
%         saveas(gcf,char(strcat(datafol,date, '/seseyev6_1/', channel,'/signalaverage_',date,'_',navsession, '_', channel,'.png')))
%         close
%         


end

                      
                         