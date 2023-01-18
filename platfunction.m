

function platfunction(curve, curveNum, peaks, troughs, threshold)
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

PeakSize = size(peaks);
PeakSize = PeakSize(1);
period = (troughs(end,1) - troughs(1,1))/PeakSize; % calculate period!!!

%period = (curve(end,1) - curve(1,1))/length(peaks(:,2));


%Determine average height between adjacent bases
for i = 2:minSize
    basewidth(i-1) = (troughs(i,1)-troughs((i-1),1));
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
pArea = platarea(baseheight,platheight,troughs,peaks,curve);
plot(peaks(:,1),peaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
plot(troughs(:,1),troughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');

for pulse=1:maxSize
    inc_high = minIndicies(pulse);
    for i=minIndicies(pulse):maxIndicies(pulse);
        inc_low = inc_high;
        low_t = i - 1;
        inc_high = curve(i,2);
        if (inc_high >= platheight(pulse))
            break
        end
    end
    
    %calculate slope
    m = (inc_high - inc_low)*10;
    %calculate difference between lower bound and platheight
    p_diff = platheight(pulse) - inc_low;
    %calculate difference between lower bound time and platheight time
    t_diff = p_diff/m;
    %estimate location of edge
    left_edge(pulse) = curve(low_t,1) + t_diff;
    hb = line([troughs(pulse,1) troughs((pulse+1),1)], [baseheight(pulse) baseheight(pulse)], 'Color', 'g','LineWidth',2);
    plot(troughs(pulse,1),baseheight(pulse), 'Color', 'g', 'Marker', 'O', 'LineStyle', 'none');
    plot(troughs(pulse,1),baseheight(pulse), 'Color', 'g', 'Marker', '+', 'LineStyle', 'none');
    plot(troughs((pulse+1),1),baseheight(pulse), 'Color', 'g', 'Marker', 'O', 'LineStyle', 'none');
    plot(troughs((pulse+1),1),baseheight(pulse), 'Color', 'g', 'Marker', '+', 'LineStyle', 'none');
    line([troughs(pulse,1) troughs(pulse,1)], [troughs(pulse,2) baseheight(pulse)], 'Color', 'c');
    line([troughs((pulse+1),1) troughs((pulse+1),1)], [baseheight(pulse) troughs((pulse+1),2)], 'Color', 'c');
    plot(left_edge(pulse),platheight(pulse), 'Color', 'm', 'Marker', 'O', 'LineStyle', 'none');
    plot(left_edge(pulse),platheight(pulse), 'Color', 'm', 'Marker', '+', 'LineStyle', 'none');
end

for pulse=maxSize:-1:1
    inc_high = minIndicies(pulse+1);
    for i=minIndicies(pulse+1):-1:maxIndicies(pulse);
        inc_low = inc_high;
        low_t = i + 1;
        inc_high = curve(i,2);
        if (inc_high >= platheight(pulse))
            break
        end
    end
    
    %calculate slope
    m = (inc_high - inc_low)*10;
    %calculate difference between lower bound and 40percent
    p_diff = platheight(pulse) - inc_low;
    %calculate difference between lower bound time and 40percent time
    t_diff = p_diff/m;
    %estimate location of edge
    right_edge(pulse) = curve(low_t,1) - t_diff;
    plot(right_edge(pulse),platheight(pulse), 'Color', 'm', 'Marker', 'O', 'LineStyle', 'none');
    plot(right_edge(pulse),platheight(pulse), 'Color', 'm', 'Marker', '+', 'LineStyle', 'none');
    hp = line([left_edge(pulse) right_edge(pulse)], [platheight(pulse) platheight(pulse)], 'Color', 'm','LineWidth',2);
end
legend([hp,hb],'Plateau Width','Base Width','Location','Northwest');
title(['Curve ', curveNum]);
xlabel('Time (min)');
ylabel('Fura-2  Ratio');
hold off;

%Create an array of plateau widths and plateau fractions
platwidth = right_edge - left_edge;
pf = platwidth ./ basewidth;

% %Determine average plateau width
% avgpf = mean(pf);
% avgpa = mean(pArea);

%Determine average plateau width added by ss 10-9-19
avgpf = mean(pf);
avgpa = mean(pArea);
avgpw = mean(platwidth);
avgbw = mean(basewidth);

for m =1:PeakSize
    Silencep(1:m)=(basewidth(1:m)-platwidth(1:m));
end

avgsp = mean(Silencep);


expoData1 = [expoData1 avgpf(1) avgpa(1) avgpw(1) avgbw(1) avgsp(1)];

% expoData1 = [expoData1 avgpf(1) avgpa(1)];

%Print plateau fractions to cmd window for each pulse
fprintf('\n');
fprintf('Average plateau fraction = %d \n',avgpf);

%Save results to outp matrix
appender = true;
while(appender)
    x = input('Do you want to export this data? (y/n) ', 's');
    if(x == 'y')
         nts = input('Additional notes: ', 's');
        for i=1:12
            outp{expoSize,i} = expoData1(i);
        end
        if ~isempty(nts)
            outp{expoSize,14} = nts;
        end
%         outp{(expoSize+1),1} = ' ';
       
        save('outp.mat','outp');
%         displayMatrix(outp);
        appender = false;
        
%         nts = input('Additional notes: ', 's');
%         for i=1:9
%             outp{expoSize,i} = expoData1(i);
%         end
%         if ~isempty(nts)
%             outp{expoSize,10} = nts;
%         end
% %         outp{(expoSize+1),1} = ' ';
%        
%         save('outp.mat','outp');
% %         displayMatrix(outp);
%         appender = false;
    elseif(x == 'n')
        appender = false;
    else
        disp('Not a valid input')
    end
end

fprintf('\n');


