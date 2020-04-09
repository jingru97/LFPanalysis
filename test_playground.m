
%error bar plot for trial periods diffrerent trial periods
%1: Cue onset(0-1)
%2: Pure movement (1-2)
%3: Pre-Cue (-1 to 0)
%4:1 second window towards end of session
%5:1st half of cue (0-0.5)
%6:2nd half of cue(0.5-1)

%note: Use this script after running spec_norm_sessioneye_final. ie after spectrogram data is generated

c1=-4;
c2=4;
datafol = '/Users/jingru/Desktop/results/Hippocampal LFP Research/';
%i=2;
%figure;
dateFolder=[dir('201807*');dir('201808*'); dir('201809*');dir('201810*');dir('2018011*') ];
dateFolder={dateFolder([dateFolder.isdir]).name};
 
for date=dateFolder
    date=char(date);
for session=1
    navsession= strcat('session0',string(session),'');                                                                   
    session_folder=strcat(datafol,date,'/', navsession);
    cd (char(session_folder))
    mkdir('poweragainstfreqplots');
    
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

            localpowerspectrum(mspec,1,50,c1,c2,datafol,date,navsession,i);
        end
        
        i=i+1;
    end
end 
end

function [Pnorm1, Pnorm2, Pnorm4, Pnorm5, Pnorm6] = localpowerspectrum(mspec,x1,x2,y1,y2,datafol,date,navsession,i)


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
    title(strcat('ZScored Power against Frequency Plot1 Channel ',num2str(i)),'FontSize',20);
    ylabel('Z-scored Power');
    

    % plot reference lines
    hold on
    line([1 1],[-100 100]) 
    line([5 5],[-100 100])
    line([6 6],[-100 100])
    line([10 10],[-100 100])
    line([0 50],[0 0],'LineStyle','--')
    line([0 50],[3 3],'LineStyle','--')
    line([0 50],[-3 -3],'LineStyle','--')
    
    hold off
    legend({'Pure Movement(1-2s)','Cue-onset(0-1s)','Pre-Cue(-1-0s)','End Trial 1s'})

    saveas(gcf,char(strcat(datafol,date,'/',navsession,'/poweragainstfreqplots/', '/errorbarPlot1_',date,'_channel_ ',num2str(i), '.png')))
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
    title(strcat('ZScored Power against Frequency Plot2 Channel ',num2str(i)),'FontSize',20);
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
    
    saveas(gcf,char(strcat(datafol,date,'/',navsession,'/poweragainstfreqplots/','/errorbarPlot2_',date,'_channel_ ',num2str(i), '.png')))
    close

    



end