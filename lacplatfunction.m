function lacplatfunction(curve, curveNum, peaks, troughs, threshold)
%      Determines left and right edges of plateau based off of user input.
%      Graphically represents plateau and base, and calculates plateau
%      width over the base width (aka the Plateau Fraction)


%Call global variable used to hold spreadsheet
global outp
expoSize = length(outp(:,1));

%Initialize arrays for later use
basewidth = [];
platwidth = [];
baseheight = [];
amplitudes = [];
minIndicies =[];
maxIndicies = [];
left_edge = [];
right_edge = [];
expoData = [];
pArea = [];
%Plateau Fractions
pf = [];

minSize = length(troughs(:,1));
maxSize = length(peaks(:,1));

%Determine parameters before messing with data

avgBaseline = mean(troughs(:,2));
avgPeak = mean(peaks(:,2));
deltaR = avgPeak - avgBaseline;
period = (curve(end,1) - curve(1,1))/length(peaks(:,2));


%Determine average height between adjacent bases
for i = 2:maxSize
    basewidth(i-1) = (peaks(i,1)-peaks((i-1),1));
    peakheight(i-1) = (peaks(i,2)+peaks((i-1),2))/2;
end

for i = 2:minSize
    baseheight(i-1) = (troughs(i,2)+troughs((i-1),2))/2;
end


%Prepare initial parameters for export
expoData1 = [curveNum maxSize avgBaseline(1) avgPeak(1) deltaR(1) period(1) threshold];

%Determine amplitude for each pulse using base midpoint
amplitudes = (peaks(:,2) - baseheight(:));
amplitudes = transpose(amplitudes);

%Ask user for plateau definition
ampperc = input('At what percent of the amplitude would you like \nto analyze the plateau fraction? (default 50) ');
if isempty(ampperc)
    ampperc = 50;
elseif (ampperc > 95)
    ampperc = 95;
elseif (ampperc < 5)
    ampperc = 5;
end
fprintf('Analyzing at %d%% of the amplitude ...\n',ampperc);
ampperc = (ampperc/100);

%Create array of plateau heights
platheight = (ampperc.*amplitudes)+baseheight;

%Determine length of curve
curveSize = length(curve(:,1));

%Scan curve for min and peak indicies
curMin = 1;
curMax = 1;
for i=1:curveSize
    if (curMin <= minSize)
        if (curve(i,1) == troughs(curMin,1))
            minIndicies = [minIndicies i];
            curMin = curMin + 1;
        end
    end
    if (curMax <= maxSize)
        if (curve(i,1) == peaks(curMax,1))
            maxIndicies = [maxIndicies i];
            curMax = curMax + 1;
        end
    end
end

f2 = figure(2);
clf;
set(f2, 'Position', [660 50 600 370]);
plot(curve(:,1), curve(:,2));
title(['Perceval curve ', num2str(curveNum)]);
xlabel('Time (min)');
ylabel(strcat('Perceval Ratio'));
grid on;

hold on;
pArea = lacperplatarea(baseheight,platheight,troughs,peaks,curve);
plot(peaks(:,1),peaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
plot(troughs(:,1),troughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');

for pulse=1:minSize-2
    
    left_edge(pulse) = troughs(pulse+1,1);
    hb = line([peaks(pulse,1) peaks((pulse+1),1)], [peakheight(pulse) peakheight(pulse)], 'Color', 'g','LineWidth',2);
%     plot(troughs(pulse,1),baseheight(pulse), 'Color', 'g', 'Marker', 'O', 'LineStyle', 'none');
%     plot(troughs(pulse,1),baseheight(pulse), 'Color', 'g', 'Marker', '+', 'LineStyle', 'none');
%     plot(troughs((pulse+1),1),baseheight(pulse), 'Color', 'g', 'Marker', 'O', 'LineStyle', 'none');
%     plot(troughs((pulse+1),1),baseheight(pulse), 'Color', 'g', 'Marker', '+', 'LineStyle', 'none');
%     line([troughs(pulse,1) troughs(pulse,1)], [troughs(pulse,2) baseheight(pulse)], 'Color', 'c');
%     line([troughs((pulse+1),1) troughs((pulse+1),1)], [baseheight(pulse) troughs((pulse+1),2)], 'Color', 'c');
end

for pulse=1:minSize-2
    plot(left_edge(pulse),platheight(pulse+1), 'Color', 'm', 'Marker', 'O', 'LineStyle', 'none');
    plot(left_edge(pulse),platheight(pulse+1), 'Color', 'm', 'Marker', '+', 'LineStyle', 'none');
end

for pulse=2:minSize-1
    
    right_edge(pulse-1) = peaks(pulse,1);
    plot(right_edge(pulse-1),platheight(pulse), 'Color', 'm', 'Marker', 'O', 'LineStyle', 'none');
    plot(right_edge(pulse-1),platheight(pulse), 'Color', 'm', 'Marker', '+', 'LineStyle', 'none');
    hp = line([troughs(pulse,1) peaks((pulse),1)], [platheight(pulse) platheight(pulse)], 'Color', 'm','LineWidth',2);
end
%legend([hp,hb],'Plateau Width','Base Width','Location','Northwest');
title(['Perceval curve ', num2str(curveNum)]);
xlabel('Time (min)');
ylabel('Perceval Ratio');
hold off;

%Create an array of plateau widths and plateau fractions
platwidth = right_edge - left_edge;
pf = platwidth ./ basewidth;
%Determine average plateau width

avgpf = mean(pf);
avgpa = mean(pArea);

expoData1 = [expoData1 avgpf(1) avgpa(1)];

%Print plateau fractions to cmd window for each pulse
fprintf('\n');
fprintf('Average plateau fraction = %d \n',avgpf);

%Save results to outp matrix
appender = true;
while(appender)
    x = input('Do you want to export this data? (y/n) ', 's');
    if(x == 'y')
        outp{1,15} = 'Laconic pulses';
        outp{1,16} = 'Laconic baseline';
        outp{1,17} = 'Laconic peak';
        outp{1,18} = 'Laconic amplitude';
        outp{1,19} = 'Laconic period';
        outp{1,20} = 'Laconic threshold';
        outp{1,21} = 'Laconic plateau Fraction';
        outp{1,22} = 'Laconic active area';
        outp{1,23} = 'Notes';
        
        nts = input('Additional notes: ', 's');
        
        for i=2:9
            outp{expoSize,i+14} = expoData1(i);
        end
        if ~isempty(nts)
            outp{expoSize,23} = nts;
        end
        
        outp{(expoSize+1),1} = ' ';
    
        save('outp.mat','outp');

        appender = false;
    elseif(x == 'n')
        appender = false;
    else
        disp('Not a valid input')
    end
end

fprintf('\n');


