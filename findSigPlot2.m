%this script attempts to filter the spectrograms of channels with
%significant power values at the cue periods.
% the signigicance is flagged when mean P value of cue period is found to
% be larger than 3 standard deviations of the mean of the corresponding eye
% session P value


x1= -0.75;
x2= 7;
y1= 1;
y2= 20;
c1=-4;
c2=4;

datafol = '/Volumes/User/jingru/Desktop/results/Hippocampal LFP Research/';
i=2;
%figure;
date_folder={'20171213'};
date=char(date_folder);


for arrayno=1:4
%Initialises array name
    array=strcat('array0',string(arrayno),'');

    %Runs the conglomerated function for each channel in each array;
    %switch for speed
            switch arrayno
                case 1 % array 1
                    for channelno=2
                        channel=channelname(channelno);
%                         try
                            cd (char(strcat( '/Volumes/Hippocampus/Data/picasso-old/20171213/sessioneye/', array, '/',channel)))
                            rp=vmlfp('auto');
                            
                            T=1;
                            for n = 1:length(rp.data.markers) % trial marker

                                if rp.data.markers(n) == 6

                                % Obtain trial index for the marker
                                % Each datapoint increases by 0.0010s, starting from index 0-
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
                            
                                                          % ===============================================================
                                % Creates a structure that averages the normalised data across all trials
                                % without standardising the time bins (but limit the data to 1s only)

                                for s=1:36 % limit the data from 0s to 2s only (average mean length of the trials)
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



                        
                        
%                         catch
%                         disp('skipped')
%                         end
                       
               
                    end

                case 2 % array 2
                    for channelno=33:64
                        channel=channelname(channelno);
                        saves the individual plots for each channel
                        [mrawspecdat(channelno).data,mspecdat(channelno).data,mvlspecdat(channelno).data]=combfun(navsession,channel,array,session,date,userfol);
                    end

                case 3 % array 3
                    for channelno=65:96
                        channel=channelname(channelno);
                        saves the individual plots for each channel
                        [mrawspecdat(channelno).data,mspecdat(channelno).data,mvlspecdat(channelno).data]=combfun(navsession, channel,array,session,date,userfol);
                    end

                case 4 % array 4
                    for channelno=97:128
                        channel=channelname(channelno);
                        saves the individual plots for each channel
                        [mrawspecdat(channelno).data,mspecdat(channelno).data,mvlspecdat(channelno).data]=combfun(navsession, channel,array,session,date,userfol);
                    end
            end
        %save(char(strcat(userfol,'/Desktop/results/Hippocampal LFP Research/',date,'/',navsession,'/',date,'_seseye_data.mat')),'mrawspecdat','mspecdat','mvlspecdat')
  end

 
for session=1:3
    navsession= strcat('session0',string(session),'');
    session_folder=strcat(datafol,date,'/', navsession);
    cd (char(session_folder))
    
    filename= dir ('*_data.mat');
    filename =filename.name;
    
    dat =load(filename);
    dat= dat.mvlspecdat;
    
    

    i=1; %tracks channel number
    k=1; %tracks plotn.o
    for i= 1:size(dat,2)
        
        mspec=dat(i).data;
        
        
        if isempty(mspec.Pnorm) ==1
            continue;
        else

            Pnorm1=mean(mean(mspec.Pnorm(1:20,16:36),2)); % Cue-onset
            Pnorm2=mean(mean(mspec.Pnorm(1:20,36:56),2)); % Pure movement
            Pstd2=mspec.Pnorm(1:20,36:56);
            Pstd2= std(Pstd2(:));  


            if Pnorm1 > 3*Pstd2 + Pnorm2

             %   subplot(4,5,k);
                
                plotspec(mspec,x1,x2,y1,y2,c1,c2);
                saveas(gcf,char(strcat(datafol,date,'/',navsession,'/norm_seseye_PS_',date,'_channel_ ',num2str(i), '.png')))
                close
               % k=k+1;

            end  
        end

        
        
        i=i+1;

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
