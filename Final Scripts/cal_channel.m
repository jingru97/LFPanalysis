cd '/Users/jingru/Desktop/results/Hippocampal LFP Research'
dateFolder=[dir('201807*');dir('201808*'); dir('201809*');dir('201810*');dir('2018011*') ];
dateFolder={dateFolder([dateFolder.isdir]).name};

num=0;
for date=dateFolder
    cd (char(strcat(date,'/session01')))
    channel=[dir('channel*')];
    num=num+size(channel,1);
    cd ../..
end
    
