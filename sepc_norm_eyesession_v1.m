%high level looping code

%get averaged PSD accross all trials for each channel in an array
%assume user is already in sessio directory
% 
% A=dir('array*');
% arrays={A([A.isdir]).name};
% 
% for a = arrays
%      cd (char(a))
%      C= dir('channel*');
%      channels={C([C.isdir]).name};
% 
%      for c= channels
%          cd (char(c))
%          vl= vmlfp('auto');
%          InspectGUI(vl,'TFfft', 'PlotAllData');
%      end
%      
% end




%This code is the first iteration of plotting a spectrogram that is average
%acrossed all trials



Args = struct('TFfftWindow',300, 'TFfftOverlap',250, ...
		    'TFfftPoints',256, 'TFfftStart',500,'TFfftFreq',150);


% loop through channels form aray directory
C=dir('channel*');
channels={C([C.isdir]).name};
channelNum=size(channels,2);
i=1;
figure;
minP=0;
maxP=0;

for c=channels(1:16)
    cd (char(c))
    vl=vmlfp('auto');

    %z-score spectrogram obtained against eye session mean and
    %standard deviation
    currentFolder= pwd;
    pathparts= strsplit(currentFolder,filesep);
    session=pathparts(7);
    array= pathparts(8);
    channel = pathparts(9);
    cd (char(strcat('../../../sessioneye/', array, '/', channel)))


    eye= vmlfp('auto');
    
    cd (char(strcat('../../../', session,'/', array)))
    eye_data= eye.data.analogData(1:1000);
    eye_datam= mean(eye_data);


   
   %get sRate of eye session data
    sRate = eye.data.analogInfo.SampleRate;
   
   %spectrogram of eye session
    [~,~,~,P_eye]=spectrogram(eye_data-eye_datam,Args.TFfftWindow,Args.TFfftOverlap,(0:50),sRate,'yaxis');
    
   %obtain mean and std across all time bins for different frequencties for eye session 
    Pmean_eye=mean(P_eye,2); %mean power density of each frequency bin
    Pstd_eye=std(P_eye,0,2); %%standard deviation of each frequency bin
    
    
    % go into navigation session lfp data

        
   % InspectGUI(vl,'TFfft', 'this', 'ZScore');
    obj=vl;
    n = size(obj.data.trialIndices,1);
    dIdx = obj.data.trialIndices(:,3) - obj.data.trialIndices(:,1); 
    % find longest trial
    mIdx = max(dIdx);
    % find number of time bins in the spectrogram that corresponds to
    spTimeStep = Args.TFfftWindow - Args.TFfftOverlap;
    spTimeBins = floor(mIdx/spTimeStep) - Args.TFfftOverlap/spTimeStep;%what does this mean
    % create matrix
    % nFreqs = (Args.TFfftPoints/2)+1;
    nFreqs= 51;
    ops = zeros(nFreqs,spTimeBins);

    opsCount = ops;

    for ti = 1:obj.data.numSets
        tIdx = obj.data.trialIndices(n,:); % Obtain trial indexes

       % Spectrogram data for the 'normalisation period NP'
        idx = (tIdx(1)-((Args.TFfftStart+500)/1000*sRate)):(tIdx(1)-((Args.TFfftStart+1)/1000*sRate));
        %Inter-trial interval data used for normalisation will always
        %be 500ms before TfftStart
        data = obj.data.analogData(idx);
        datam = mean(data);
        [~,~,~,P]=spectrogram(data-datam,Args.TFfftWindow,Args.TFfftOverlap,(0:50),sRate,'yaxis');

          %  Normalization parameters of the NP
        Pmean=mean(P,2); %mean power density of each frequency bin
        Pstd=std(P,0,2); %standard deviation of each frequency bin


            %     Spectrogram data for trials
        idx = (tIdx(1)-(Args.TFfftStart/1000*sRate)):tIdx(3);
        %Trial data including pre-trial data of duration determined by TfftStart
        data = obj.data.analogData(idx);
        datam = mean(data);
        [spec.S,spec.F,spec.T,spec.P,spec.Fc,spec.Tc]=...
            spectrogram(data-datam,Args.TFfftWindow,Args.TFfftOverlap,(0:50),sRate,'yaxis');

       % trial psd normalised to NP
        spec.Pnorm=(spec.P-Pmean)./Pstd;
        spec.T=(-Args.TFfftStart/1000:(Args.TFfftWindow-Args.TFfftOverlap)/sRate:spec.T(end)-(Args.TFfftStart/1000+Args.TFfftWindow/sRate/2));

        % trial psd normalised to eye session data
        spec.Pnorm=(spec.Pnorm-Pmean_eye)./Pstd_eye;

        
        

        %update ops
        psIdx = 1:size(spec.Pnorm,2);

        ops(:,psIdx) = ops(:,psIdx) + spec.Pnorm;

        opsCount(:,psIdx) = opsCount(:,psIdx) + 1;



    end

    ops=ops./opsCount;
    ops(:,any(isnan(ops), 1))=[]; 
    
    minP1= min(min(ops));
    maxP1= max(max(ops));
    
    if minP1 < minP
        minP= minP1;
    end
        
    
    if maxP1 > maxP
    maxP= maxP1;
    end
    
    hAx(i)=subplot(4,4,i);
    colormap('hot');

    
    
    imagesc(0:(Args.TFfftWindow-Args.TFfftOverlap):mIdx,0:(sRate/Args.TFfftPoints):(sRate/2),ops)

  %  set(gca,'Ydir','normal')

       
    i =i+1;   

   
end

disp('end');

i=1;
for c=channels(1:16)
   
   subplot(4,4,i);
   
   caxis manual;
   caxis([minP maxP]);
   
   
   i=i+1; 
end



colorbar;



%linkaxes(hAx,'y')
%set(hAx,'ylim',[0 200])


disp('end');
    





         
         
         
         
         
         
        
    
