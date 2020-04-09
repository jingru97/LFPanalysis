%this script checks for significant actuvities in the cue period versus
%navigation period.


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
 
for session=1
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


            if Pnorm1 > Pstd2 + Pnorm2

             %   subplot(4,5,k);
                
                plotspec(mspec,x1,x2,y1,y2,c1,c2);
                mkdir('good');
                cd good;
                saveas(gcf,char(strcat(datafol,date,'/',navsession,'/norm_seseye_PS_',date,'_channel_ ',num2str(i), '.png')))
                close
                cd ..
               % k=k+1;
               
            else
                
                plotspec(mspec,x1,x2,y1,y2,c1,c2);
                mkdir('bad');
                cd bad;
                saveas(gcf,char(strcat(datafol,date,'/',navsession,'/norm_seseye_PS_',date,'_channel_ ',num2str(i), '.png')))
                close
                cd ..
                
                

            end  
        end

        
        
        i=i+1;

    end
    
end




        

    
   
    
    
