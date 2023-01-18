function [avgBaseline, avgPeak, deltaR, period] = analyzeSpikes(mCurve, mCurveType, curveNum, dCurve, dCurveType)
%returns average baseline, average peak, average amplitude, average period.
%takes in curve and curveNumber.  dData is optional.

%Call global variable used to hold spreadsheet
global outp
expoSize = length(outp(:,1));

mPeakSize = 0;
while(mPeakSize == 0) %while no peaks detected, calculate peaks and troughs
    mThreshold = input('Please enter the spike threshold (default = .04): ', 's');
    mThreshold = str2num(mThreshold);
    if isempty(mThreshold)
        mThreshold = .04;
    end
    
    if(mCurveType == 'Fura')
        [mPeaks, mTroughs] = peakdetectv1(mCurve(:, 2),mThreshold, mCurve(:,1));
    else
        [mPeaks, mTroughs] = peakdetect(mCurve(:, 2),mThreshold, mCurve(:,1)); %try to detect peaks with threshold using peakDetect
    end
    nth = 1; %???
    mTroughSize = size(mTroughs);
    mTroughSize = mTroughSize(1); %grab the first value, the number of troughs.
    mPeakSize = size(mPeaks);
    mPeakSize = mPeakSize(1);
    platter = true; % assume peaksize > 0, we can analyze this.

    if(mPeakSize ~= 0)
        if (mPeaks(1,1) < mTroughs(1,1))
            mPeaks = mPeaks(2:mPeakSize,:); %remove first peak point if it is before the first trough point
            mPeakSize = mPeakSize - 1; %adjust peakSize by -1
        end
        if (mPeaks(mPeakSize,1) > mTroughs(mTroughSize,1)) %remove last peak point if it is after the last trough point
            mPeaks = mPeaks(1:mPeakSize,:);
            mPeakSize = mPeakSize - 1;
        end
    end

    if(mPeakSize == 0)
        avgBaseline = 0;
        avgPeak = 0;
        deltaR = 0;
        period = 0;
        clc
        fprintf('\nNo peaks detected!\n');
        platter = false; % do not try to analyze this (yet)!!  ask for another threshold.
    end
    
end

f2 = figure(2); %figure 2
clf; %clear figure 2 window
set(f2, 'Position', [660 50 600 370]);
plot(mCurve(:,1), mCurve(:,2));
title([mCurveType, ' curve ', num2str(curveNum)]);
xlabel('Time (min)');
ylabel(strcat(mCurveType, ' Ratio'));
grid on;

hold on;
plot(mPeaks(:,1),mPeaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
plot(mTroughs(:,1),mTroughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');
hold off;

avgBaseline = mean(mTroughs(:,2)); %average baseline = average trough y values
avgPeak = mean(mPeaks(:,2)); % average peak = average peak y values
deltaR = avgPeak - avgBaseline; %deltaR = average amplitude
%len = length(mPeaks(:,2));
%period = (mCurve(end,1) - mCurve(1,1))/mPeakSize; % calculate period!!!
lenTest = mTroughs(end,1) - mTroughs(1,1);
period = lenTest / mPeakSize;
period = (mTroughs(end,1) - mTroughs(1,1))/mPeakSize; % calculate period!!!

fprintf('\n');

while(platter)
    clc
    
    fprintf('You chose to analyze curve %s!\n', num2str(curveNum))
    disp('q - Return to previous menu')
    fprintf('1 - Adjust %s Threshold\n', mCurveType)
    fprintf('2 - Detrend %s Curve\n', mCurveType)
    fprintf('3 - Investigate %s Plateau Fraction\n', mCurveType)
    
    if (exist('dCurve', 'var'))
        fprintf('4 - Adjust %s threshold and detrend\n', dCurveType)
        disp('5 - Analyze fraction ER contribution')
        fprintf('6 - Investigate %s Plateau Fraction\n', dCurveType)
    end
    
    x = input('What would you like to do: ', 's');
    
    y = str2num(x);
    clc
    
    if(x == 'q')
        outp{(expoSize+1),1} = ' ';
        displayMatrix(outp);
        platter = false;
         
    elseif(y == 1)
        if (exist('dCurve', 'var'))
            analyzeSpikes(mCurve, mCurveType, curveNum, dCurve, dCurveType)
        else
            analyzeSpikes(mCurve, mCurveType, curveNum);
        end
        platter = false; 
        
    elseif(y == 2)
        f2 = figure(2); %figure 2
        clf;
        set(f2, 'Position', [660 50 600 370]);
        plot(mCurve(:,1), mCurve(:,2));
        title([mCurveType, ' curve ', num2str(curveNum)]);
        xlabel('Time (min)');
        ylabel(strcat(mCurveType, ' Ratio'));
        grid on;
        
        hold on;
        plot(mPeaks(:,1),mPeaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
        plot(mTroughs(:,1),mTroughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');
        hold off;
        
        [mPeaks, mTroughs, mCurve, nth] = flatten(mPeaks, mTroughs, mCurve);
        
        mCurveYs = mCurve(:, 2);
        avgY = mean(mCurveYs);
        expoSize = length(outp(:,1));

        outp{expoSize, 11} = avgY;
        disp('Average Y value was changed!');
        
    elseif(y == 3)
        if (strcmp(mCurveType, 'Fura'))
            platfunction(mCurve, curveNum, mPeaks, mTroughs, mThreshold);
        elseif (strcmp(mCurveType, 'Perceval'))
            perplatfunction(mCurve, curveNum, mPeaks, mTroughs, mThreshold);
        elseif (strcmp(mCurveType, 'Laconic'))
            lacplatfunction(mCurve, curveNum, mPeaks, mTroughs, mThreshold);
        end
        
    elseif(y == 5)
        if (~exist('dThreshold', 'var'))
            [dCurve, dTroughs, dPeaks, dThreshold] = analyzeDSpikes(curveNum, dCurve, dCurveType);
        end
        
        integrateTail(mCurve, mTroughs, mPeaks, mCurveType, curveNum, dTroughs, dPeaks, dCurve, dCurveType);
        
    elseif (y == 6)
        
        %use threshold for plateau fraction analysis- trusts the user to
        %already have the threshold from the detrending 
        if (strcmp(dCurveType, 'Perceval'))
            perplatfunction(dCurve, curveNum, dPeaks, dTroughs, dThreshold);
        elseif (strcmp(dCurveType, 'Laconic'))
            lacplatfunction(dCurve, curveNum, dPeaks, dTroughs, dThreshold);
        end
        
    elseif (y==4)
        %generate threshold
        [dCurve, dTroughs, dPeaks, dThreshold] = analyzeDSpikes(curveNum, dCurve, dCurveType);
        
        f2 = figure(2); %figure 2
        clf;
        set(f2, 'Position', [660 50 600 370]);
        plot(dCurve(:,1), dCurve(:,2));
        title([dCurveType, ' curve ', num2str(curveNum)]);
        xlabel('Time (min)');
        ylabel(strcat(dCurveType, ' Ratio'));
        grid on;
        
        hold on;
        plot(dPeaks(:,1),dPeaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
        plot(dTroughs(:,1),dTroughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');
        hold off;
        
        f1 = figure(1);
        clf;
        set(f1, 'Position', [500 50 600 370]);
        plot(dCurve(:,1), dCurve(:,2)); %plot all values in first curve column = x, all values in second curve column = y.
        grid on;
        title([dCurveType, ' curve ', num2str(curveNum)]);
        xlabel('Time (min)');
        ylabel(strcat(dCurveType, ' Ratio'));
        
        %detrend dCurve
        [dPeaks, dTroughs, dCurve, nth] = flatten(dPeaks, dTroughs, dCurve);
        
    else
        h = msgbox('Not a valid input');
        
    end
    
    
    
    if (y == 2)
        if (mPeaks(end,1) > mTroughs(end,1))
            mPeaks = mPeaks(1:(end-1),:);
        end
        f2 = figure(2);
        clf;
        set(f2, 'Position', [660 50 600 370]);
        plot(mCurve(:,1), mCurve(:,2));
        title([mCurveType, ' curve ', num2str(curveNum)]);
        xlabel('Time (min)');
        ylabel(strcat(mCurveType, '  Ratio'));
        grid on;
        hold on;
        plot(mPeaks(:,1),mPeaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
        plot(mTroughs(:,1),mTroughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');
        hold off;
    end
    
    if (y == 4)
        if (dPeaks(end,1) > dTroughs(end,1))
            dPeaks = dPeaks(1:(end-1),:);
        end
        f2 = figure(2);
        clf;
        set(f2, 'Position', [660 50 600 370]);
        plot(dCurve(:,1), dCurve(:,2));
        title([dCurveType, ' curve ', num2str(curveNum)]);
        xlabel('Time (min)');
        ylabel(strcat(dCurveType, '  Ratio'));
        grid on;
        hold on;
        plot(dPeaks(:,1),dPeaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
        plot(dTroughs(:,1),dTroughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');
        hold off;
    end
end
clc
