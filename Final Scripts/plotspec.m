% Powerspectrum plots the processed spectrogram
% Inputs: mspec = processed spectrogram data, x1 and x2 defines the x-axis, y1 and y2 defines the y-axis, c1 and c2 defines the colour axis
% Outputs: Spectrogram plot

function plotspec(mspec,x1,x2,y1,y2,c1,c2)



%%NOTE: comment below statement to create figure when using findSigPlot function

figure('Position', get(0, 'Screensize'))
surf(mspec.T,mspec.F,mspec.Pnorm,'EdgeColor','none');
axis xy; 
axis([x1 x2 y1 y2]); 
colormap(jet); 
view(0,90);
caxis([c1 c2]);
%axis xy; axis([x1 x2 y1 y2]); colormap(jet); caxis([c1 c2]);



%%NOTE: comment below statement to create figure when using findSigPlot function

set(gca,'FontSize',15); xticks(-1:0.5:x2); yticks(0:5:y2);
title('Normalised PSD averaged for all trials','FontSize',20);

xlabel('Time (s)'); ylabel('Frequency (Hz)');
colorbar;
 
% Plot lines to mark the cue presentation period
hold on
line([0 0],[0 250],[100 100; 100 100],'Color','k');
line([1 1],[0 250],[100 100; 100 100],'Color','k');
hold off
 
end
