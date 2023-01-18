function erAvg = integrateTail(mCurve, mTroughs, mPeaks, mCurveType, curveNum, dTroughs, dPeaks, dCurve, dCurveType)
%plot fura graph
avgBaseline = mean(mTroughs(:,2));


f5 = figure(5);
clf;
set(f5, 'Position', [660 50 600 370]);
plot(mCurve(:,1), mCurve(:,2));
title([mCurveType, ' curve ', num2str(curveNum)]);
xlabel('Time (min)');
ylabel([mCurveType, ' Ratio']);
grid on;

hold on;
plot(mPeaks(:,1),mPeaks(:,2), 'Color', 'r', 'Marker', '*', 'LineStyle', 'none');
plot(mTroughs(:,1),mTroughs(:,2), 'Color', 'g', 'Marker', '*', 'LineStyle', 'none');


%Call global variable used to hold spreadsheet
global outp
expoSize = length(outp(:,1));

dTroughsTimes = dTroughs(:, 1);
dPeaksTimes = dPeaks(:, 1);
mTroughsTimes = mTroughs(:, 1);
mPeaksTimes = mPeaks(:, 1);
i = 1;
erIntegrals = [];
cytIntegrals = [];
fractions = [];

mCurveYs = mCurve(:, 2);
mCurveXs = mCurve(:, 1);

dCurveXs = dCurve(:, 1);




while (i <= length(dTroughsTimes) && i <= length(mTroughsTimes)-1)
    cytBeginning = find(mCurveXs == mTroughsTimes(i));
    ending = find(mCurveXs == mTroughsTimes(i+1));
    if (strcmp(dCurveType,'Perceval'))
        erBeginning = find(mCurveXs == dTroughsTimes(i)); % percival trough defines end of active phase
    elseif (strcmp(dCurveType, 'Laconic'))
        erBeginning = find(mCurveXs == dPeaksTimes(i)); % laconic peak defines end of active phase
    end
    
% furatrough1 has to be before pertrough1, and pertrough1 has to be before
% furatrough2, etc.

% pertrough1 has to be after furatrough1 and before furatrough2
        
    Xs = mCurveXs(cytBeginning:ending);
    Ys = mCurveYs(cytBeginning:ending);

    %account for case: perTrough1<furaTrough1
    c = i;
    while (mCurveXs(erBeginning) < mCurveXs(cytBeginning))
        if (strcmp(dCurveType,'Perceval'))
            erBeginning = find(mCurveXs == dTroughsTimes(c)); % percival trough defines end of active phase
        else
            erBeginning = find(mCurveXs == dPeaksTimes(c)); % laconic peak defines end of active phase
        end
        c = c + 1;
    end

    %account for case: perTrough1>furaTrough2
    b = i;
    while (mCurveXs(erBeginning) > mCurveXs(ending))
        try
            cytBeginning = find(mCurveXs == mTroughsTimes(b));
            ending = find(mCurveXs == mTroughsTimes(b+1));
            b = b + 1;
        catch
            break
        end
    end

    ERXs = mCurveXs(erBeginning:ending);
    ERYs = mCurveYs(erBeginning:ending);
    
    %area(ERXs, ERYs, avgBaseline); % color area integrated
    
    subER = [];
    subC = [];
    
    subER(1:length(ERXs), 1) = avgBaseline;
    
    erInteg = trapz(ERXs, ERYs) - trapz(ERXs, subER); %subtract AUC from baseline to 0
    
    subC(1:length(Xs), 1) = avgBaseline;
    
    cytInteg = trapz(Xs, Ys) - trapz(Xs, subC);

    if (mCurveXs(ending) - mCurveXs(cytBeginning) >= 1.5)  %assumes time units are minutes
        cytIntegrals(end+1) = cytInteg;
        erIntegrals(end+1) = erInteg;
        fractions(end+1) = erInteg/cytInteg;
        line([mCurveXs(erBeginning), mCurveXs(ending)], [avgBaseline,avgBaseline]);
    end
    
    
    i = i + 1;
end


erAvg = mean(erIntegrals);
cytAvg = mean(cytIntegrals);
fractionAvg = mean(fractions);


appender = true;
while(appender)
    x = input('Do you want to export this data? (y/n) ', 's');
    if(x == 'y')
        
        
        nts = input('Additional notes: ', 's');
        
        outp{expoSize, 12} = erAvg;
        outp{expoSize, 13} = cytAvg;
        outp{expoSize, 14} = fractionAvg;
        
        if ~isempty(nts)
            outp{expoSize,10} = nts;
        end
        %outp{(expoSize+1),1} = ' ';
       
        save('outp.mat','outp');
        displayMatrix(outp);
        appender = false;
    elseif(x == 'n')
        appender = false;
    else
        disp('Not a valid input')
    end
end

fprintf('\n');