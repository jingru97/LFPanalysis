%get average of all trials
%go to sepcific session, array and channel directory
obj=vmlfp('auto');
trialIndices= obj.data.trialIndices;
PreTrial=500;
TFfftStart=500;
TFfftOverlap=150;
TFfftWindow=200;
TFfftPoints=256;

totalTrial=size(trialIndices,1);


%z-score spectrogram obtained against eye session mean and
%standard deviation   
currentFolder= pwd;
pathparts= strsplit(currentFolder,filesep);
session=pathparts(7);
array= pathparts(8);
channel = pathparts(9);
cd (char(strcat('../../../sessioneye/', array, '/', channel)))

eye= vmlfp('auto');
eye_data= eye.data.analogData;
eye_datam= mean(eye_data);
cd (char(strcat('../../../', session,'/', array, '/', channel)))

%spectrogram
[~,~,~,P_eye]=spectrogram(eye_data-eye_datam,TFfftWindow,TFfftOverlap,TFfftPoints,sRate,'yaxis');


Pmean_eye=mean(P_eye,2); %mean power density of each frequency bin
Pstd_eye=std(P_eye,0,2); %%standard deviation of each frequency bin


%find longest trial
if(OldMarkerFormat)
    dIdx = diff(obj.data.trialIndices,1,2);
else
    dIdx = trialIndices(:,3) - trialIndices(:,1);
end
% find longest trial
mIdx = max(dIdx);

% find number of time bins in the spectrogram that corresponds to
spTimeStep = Args.TFfftWindow - Args.TFfftOverlap;
spTimeBins = floor(mIdx/spTimeStep) - Args.TFfftOverlap/spTimeStep;





% loop through all n trials

for n= 1:totalTrial
    tIdx = trialIndices(n,:);  
    if(length(tIdx)==2)
    OldMarkerFormat = 1;
    else
    OldMarkerFormat = 0;
    end
    sRate = obj.data.analogInfo.SampleRate;  
    if(OldMarkerFormat)
    idx = (tIdx(1)-(PreTrial/1000*sRate)):tIdx(2);
    else
    idx = (tIdx(1)-(PreTrial/1000*sRate)):tIdx(3);

    end
    %     Spectrogram data for the 'normalisation period NP'
    idx = (tIdx(1)-((TFfftStart+500)/1000*sRate)):(tIdx(1)-((TFfftStart+1)/1000*sRate));

    %Inter-trial interval data used for normalisation will always
    %be 500ms before TfftStart
    data = obj.data.analogData(idx);
    datam = mean(data);
    [~,~,~,P]=spectrogram(data-datam,TFfftWindow,TFfftOverlap,TFfftPoints,sRate,'yaxis');

     % Normalization parameters of the NP
    Pmean=mean(P,2); %mean power density of each frequency bin
    Pstd=std(P,0,2); %standard deviation of each frequency bin

    %     Spectrogram data for trials
    idx = (tIdx(1)-(TFfftStart/1000*sRate)):tIdx(3);
    %Trial data including pre-trial data of duration determined by TfftStart
    data = obj.data.analogData(idx);
    datam = mean(data);
    [spec.S,spec.F,spec.T,spec.P,spec.Fc,spec.Tc]=...
       spectrogram(data-datam,TFfftWindow,TFfftOverlap,TFfftPoints,sRate,'yaxis');

    % trial psd normalised to NP
    spec.Pnorm=(spec.P-Pmean)./Pstd;
    spec.T=(-TFfftStart/1000:(TFfftWindow-TFfftOverlap)/sRate:spec.T(end)-(TFfftStart/1000+TFfftWindow/sRate/2));

    % trial psd normalised to eye session data
    spec.Pnorm=(spec.Pnorm-Pmean_eye)./Pstd_eye;
    
end
 
 



