%pick out good trials from unity object and observe spectrum and time
%series of these good trials
%loop through every session

um= umaze('auto');
goodTrials =um.data.processTrials;
%goodTrials = goodTrials';

%cd to the array and specific channel

vl = vmlfp('auto');

for n= goodTrials
    
    