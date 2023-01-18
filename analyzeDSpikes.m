function [dCurve, dTroughs, dPeaks, dThreshold] = analyzeDSpikes(curveNum, dCurve, dCurveType)

%plot dData
%dCurve = [dData(:,1), dData(:, curveNum+1)];
f3 = figure(3);
clf;
set(f3, 'Position', [500 50 600 370]);
plot(dCurve(:,1), dCurve(:,2));
grid on;
title([dCurveType, ' curve ', num2str(curveNum)]);
xlabel('Time (min)');
ylabel(strcat(dCurveType, '  Ratio'));
     
%get peaks, troughs from perData
peakSize = 0;
while(peakSize == 0)
    dThreshold = input('Please enter the spike threshold (default = .04): ', 's');
    dThreshold = str2num(dThreshold);
    if isempty(dThreshold)
        dThreshold = .04;
    end

    [dPeaks, dTroughs] = peakdetect(dCurve(:, 2),dThreshold, dCurve(:,1));
    nth = 1;
    troughSize = size(dTroughs);
    troughSize = troughSize(1);
    peakSize = size(dPeaks);
    peakSize = peakSize(1);
    platter = true;
    
    if(peakSize == 0)
        avgBaseline = 0;
        avgPeak = 0;
        deltaR = 0;
        period = 0;
        clc
        fprintf('\nNo peaks detected!\n');
        platter = false;
    elseif (dPeaks(peakSize,1) > dTroughs(troughSize,1))
        peakSize = peakSize - 1;
        dPeaks = dPeaks(1:peakSize,:);
    end
    
    

    if(peakSize ~= 0)
        %Remove peaks that aren't between minimum points
        if (dPeaks(1,1) < dTroughs(1,1))
            dPeaks = dPeaks(2:peakSize,:);
            peakSize = peakSize - 1;
        end
        %plot peaks and ask if threshold is okay
        f4 = figure(3);
        clf;
        set(f4, 'Position', [660 50 600 370]);
        plot(dCurve(:,1), dCurve(:,2));
        title([dCurveType, ' curve ', num2str(curveNum)]);
        xlabel('Time (min)');
        ylabel(strcat(dCurveType, ' Ratio'));
        grid on;

        hold on;
        plot(dPeaks(:,1),dPeaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
        plot(dTroughs(:,1),dTroughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');
        hold off;

        answer = input('Is this threshold okay (y/n)? ', 's');
        if (answer == 'n')
            peakSize = 0;
        elseif (answer ~= 'y')
            h = msgbox('Not a valid input');
        end
        
    end
    
    
end


