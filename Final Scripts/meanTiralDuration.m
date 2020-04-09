%this script finds the mean trial durations from all the days

cd /Volumes/Hippocampus/Data/picasso-misc
dateFolder=[dir('201807*');dir('201808*'); dir('201809*');dir('201810*');dir('2018011*') ];
dateFolder={dateFolder([dateFolder.isdir]).name};
cdiff = [];

for date= dateFolder  
    cd (char(strcat('/Volumes/Hippocampus/Data/picasso-misc/', date, '/session01'))) 
    rpl= rplparallel('auto');
    time=rpl.data.timeStamps;
    diff= time(:,3) - time(:,1); 
    cdiff = [cdiff; diff];
    
end

 mean_diff = mean(cdiff)
   