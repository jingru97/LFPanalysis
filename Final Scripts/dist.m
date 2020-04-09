%This script finds 
%significant channels with Zcored-power > 3

%(1)the time bin distributions accross all sig channels 
%(2)frequency distribution accross all sig channels
%(3)channel distribution for different freq bins

%input: all spectrogram parameters
%output histogram distributions of (1), (2) and heatmaps for (3)


datafol = '/Users/jingru/Desktop/results/Hippocampal LFP Research/';
cd (datafol) 
dateFolder=[dir('201807*');dir('201808*'); dir('201809*');dir('201810*');dir('2018011*') ];
dateFolder={dateFolder([dateFolder.isdir]).name};
smap = zeros(251,216); %sig channel dist at all freq, all time
collapsed_smap = zeros(50, 216); %sig channel dist at collapsed freq bins of 5 hz intervals
freqbins= 1:5:250;  %freq distribution of all sig channels
freqdist= zeros(1,50);
channelmap = zeros(800,8);  %channnel distributionns of all freq bins (1-5, 6-10, 11-15 etc...)
cmap1 = zeros(800,8);


for date = dateFolder
   % disp(strcat('Entered new day',char(date)))
    for session=1
        navsession= strcat('session0',string(session),'');                                                                   
        session_folder=strcat(datafol,date,'/', navsession);
        cd (char(session_folder))

        filename= dir ('*_data.mat');
        disp('reading spectrogram data')
        filename =filename.name;

        dat =load(filename);
        dat= dat.mvlspecdat; %get spectrogram parameters 
        
       
        for i= 1:size(dat,2)
            
       
            mspec=dat(i).data;

            if isempty(mspec.Pnorm) ==1
                continue;
            else
               % disp(strcat('entered channel ', num2str(i)))
                Pnorm= mspec.Pnorm;
                [smap, channelfreqdist]=specmap(Pnorm,smap);
                
                k=1;
                for nfreq = 2:5:251
                    
                    collapsed_smap(k,:) = collapsed_smap(k,:) + sum(smap(nfreq:nfreq+4,:),1);
                    
                    if sum(sum(channelfreqdist(nfreq:nfreq+4, :))) >0
                        freqdist (1,k) = freqdist(1,k) + 1;
                    end
                    k=k+1;
                end
                
                [channelmap, cmap]= channeldist(Pnorm,i,channelmap,date);
                cmap1 = cmap1 + cmap;
      
            end

        end
    end 
end

%plot freq distribution
% figure;
% bar(freqbins,freqdist)
% xticks(0:20:250)
% xlabel('frequency bins')
% ylabel('n.o of Channels')
% title('Total n.o of significant channels per frequency bin')
% 
% saveas(gcf,char(strcat(datafol,'FreqDist_totalchannel','.png')))
% close
% 
% figure;
% bar(freqbins,freqdist./9.87)
% xticks(0:20:250)
% xlabel('frequency bins')
% ylabel('Percentage of Channels')
% title('Percentage of significant channels per frequency bin')
% 
% saveas(gcf,char(strcat(datafol,'FreqDist_percentagechannel','.png')))
% close
% 
% %plot channel summary of spectrogram
% figure;
% imagesc(smap)
% set(gca,'YDir', 'normal')
% colormap(jet)
% colorbar;
% title('Total n.o of significant channels per freq over whole Trial Duration')
% xlabel('Time(s)')
% ylabel('Freq(Hz)')
% saveas(gcf,char(strcat(datafol,'SpectrumDist','.png')))
% close
% figure;
% imagesc(collapsed_smap)
% set(gca,'YDir', 'normal')
% colormap(jet);
% colorbar;
% title('Total n.o of significant channels per freq bin over whole Trial Duration')
% xlabel('Time(s)')
% ylabel('Freq(Hz)')
% saveas(gcf,char(strcat(datafol,'SpectrumDist_collapsed','.png')))
% close


%plot 50 channel dist plots
for i = 1:50
    if i==1
        y= channelmap(i:i+15,:);
        z= cmap1(i:i+15,:);
        
    else    
        y= channelmap((i-1)*16+1:(i)*16,:);
        z= cmap1((i-1)*16+1:(i)*16,:);
    end
    
%     figure; 
%     subplot(2,1,1);
%     imagesc(y./15);
%     title(strcat('Channel Distribution of Frequency ', num2str(i*5-4), ' to ', num2str(i*5)))
%     colormap(jet);
%     colorbar;
%     subplot (2,1,2);
%     imagesc(y);
%     colormap(jet);
%     colorbar;
%     saveas(gcf,char(strcat(datafol,'channelDist_cueonset', '_Freq', num2str(i*5-4), 'to',num2str(i*5), '.png')))
%     close
    rem1= rem(i,4);
    if rem1 ==0
        rem1=4;
    end
        
    if rem1==1
        figure;
    end
    
    subplot(2,2,rem1)
    imagesc(z);
    title(strcat('Channel Distribution of Frequency ', num2str(i*5-4), ' to ', num2str(i*5)))
    colormap(jet);
    colorbar;
    
    if rem1==4 || i==50
        saveas(gcf,char(strcat(datafol,'channelDist__noofchanels', '_SummaryPlots',num2str(i), '.png')))
        close
    
    end
    
end







function [smap,channelfreqdist] = specmap(Pnorm,smap)
    channelfreqdist = zeros(251,216);
    for r= 1:size(Pnorm,1)
        for c=1: size(Pnorm,2)
            if (Pnorm(r,c)>3) || (Pnorm(r,c) < -3)
                smap(r,c) =smap(r,c) +1; 
                channelfreqdist(r,c) = channelfreqdist(r,c) +1;
                
            end
        end
        
    end
end


function [channelmap,cmap]= channeldist(Pnorm,i,channelmap,date)
  cmap = zeros(800,8);
  ending=1;  
  for nfreq = 2:5:251
    Pnorm1= Pnorm(nfreq:nfreq+4,:);
        starting=ending;
        ending= starting+15;
        
      
  
        for r= 1:size(Pnorm1,1)
            for c=1: size(Pnorm1,2)
                if (Pnorm1(r,c)>3) || (Pnorm1(r,c) < -3)
                    disp(Pnorm1(r,c));
                    disp(date);
                    
                    if i <=6 
                        channelmap(starting,8-i) = channelmap(starting,8-i) +1;
                        cmap(starting,8-i) = 1;
                       
                        
                    elseif i>=119 
                        if i ==119 || i ==123
                            channelmap(ending,rem(i,8)) = channelmap(ending,rem(i,8)) +1;
                            cmap(ending,rem(i,8)) = 1;
                         
                        elseif i==122
                            channelmap(ending,4) = channelmap(ending,4) +1;
                            cmap(ending,4) = 1; 
                          
                           
                        elseif i==121
                            channelmap(ending,5) = channelmap(ending,5) +1;
                            cmap(ending,5) = 1;
                           
                            
                        else    
                            channelmap(ending,6) = channelmap(ending,6) +1; 
                            cmap(ending,6) = 1;
                            
                        end
                   
                    elseif rem(i,8) ==7
                        channelmap(starting+floor(i/8)+1,8) = channelmap(starting+floor(i/8)+1,8) +1;
                        cmap(starting+floor(i/8)+1,8) = 1;
                        
                    else
                        channelmap(starting+floor(i/8),8-rem(i,8)-1) = channelmap(starting+floor(i/8),8-rem(i,8)-1) +1;
                   
                        cmap(starting+floor(i/8),8-rem(i,8)-1) = 1;
                    end   
                end
            end
        
        end
        ending=ending+1;
  end      




end
