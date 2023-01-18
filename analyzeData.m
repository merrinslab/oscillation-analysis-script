function analyzeData(mData, dData)
%mData is the data to be measured (fura, percival, or laconic).  dData is the delineating data used for
%ER calculations (perceval or laconic).

%Determine the sensor types
checking = true;
while(checking)
    if (nargin == 1)
        disp('F - Fura')
        disp('P - Perceval')
        disp('L - Laconic')
        mCurveType = input(['Which sensor is ', inputname(1), '? (q to quit) '], 's');
        if (mCurveType == 'q')
            return;
        elseif (mCurveType ~= 'F' && mCurveType ~= 'P' && mCurveType ~= 'L')
            h = msgbox('Not a valid input');   
        else
            checking = false;
        end

    elseif (nargin > 1)
        mCurveType = 'F';
        disp('P - Perceval');
        disp('L - Laconic');
        dCurveType = input(['Which sensor is ', inputname(2), '? (q to quit)'], 's');
        if (dCurveType == 'q')
            return;
        elseif (dCurveType ~= 'P' && dCurveType ~= 'L')
            h = msgbox('Not a valid input');
        else
            if (dCurveType == 'P')
                dCurveType = 'Perceval';
            elseif (dCurveType == 'L')
                dCurveType = 'Laconic';
            end
            checking = false;
        end
    end
end

if (mCurveType == 'F')
    mCurveType = 'Fura';
elseif (mCurveType == 'P')
    mCurveType = 'Perceval';
elseif (mCurveType == 'L')
    mCurveType = 'Laconic';
end

    

%data is a matrix: 1st column is time, with all other columns intensities.
%prints out the data.

dimensions = size(mData);
numberOfCurves = dimensions(2) - 1;

global outp
outp = {'Region'};
outp{1,2} = 'Pulses';
outp{1,3} = 'Baseline';
outp{1,4} = 'Peak';
outp{1,5} = 'Amplitude';
outp{1,6} = 'Period';
outp{1,7} = 'Threshold';
outp{1,8} = 'Plateau Fraction';
outp{1,9} = 'Active Area';
outp{1,10} = 'Average platwidth';
outp{1,11} = 'Average basewidth';
outp{1, 12} = 'Silent Phase';
outp{1, 13} = 'Average y value';
outp{1, 14} = 'Notes';

% outp{1,10} = 'Notes';
% outp{1, 11} = 'Average y value';

if (nargin > 1)
    outp{1,15} = 'ER Ca';
    outp{1, 16} = 'Cyt Ca';
    outp{1, 17} = 'Fraction ER/Cyt Ca';
end
outp{2,1} = ' ';
blankTemplate = outp;

while(true)
    clc %clears command window
    curveNum = input(['There are ', num2str(numberOfCurves), ' curves in this file.\nWhich curve would you like to display (q to quit, i to import)? '], 's'); %return input as string
    fprintf('\n');
    y = str2num(curveNum);
    if(curveNum == 'q')
        outSize = size(outp);
        outSize = outSize(1);
        if (outSize > 2) %if a curve was analyzed, save as current time.xls
            customName = input('Save file as: ', 's');
            disp('Saving data ...')
            c = clock;
            if (c(5) < 10)
                minute = [num2str(0) num2str(c(5))];
            else
                minute = num2str(c(5));
            end
            if isempty(customName)
                fname = ['pulseData_' num2str(c(4)) minute '.xls'];
            else
                fname = [customName '.xls'];
            end
            
            %calculate average values for each column.
            
            i = 1;
            [rows, columns] = size(outp);
            while (i < columns)
                if (i == 1)
                    tmp = cell2mat(outp(2:end-1, i));
                else
                    tmp = cell2mat(outp(2:end-2, i));
                end
                avg = mean(tmp);
                outp{rows+1, i} = avg;
                i = i + 1;
            end
                        
            xlswrite(fname,outp);
        end
        return;
        
    elseif(curveNum == 'i')
        clc
        disp('You have chosen to import previous data!')
        disp('q - go back')
        disp('1 - Import outp.mat')
        disp('2 - Import excel spreadsheet')
        x = input('What would you like to do: ', 's');
        pik = str2num(x);
        if (pik == 1)
            load('outp.mat');
            displayMatrix(outp);
            h = msgbox('You have imported outp.mat');
        elseif (pik == 2)
            fname = input('\nWhat is the file name? (ie fname.xls) ', 's');
            A = exist(fname);
            if (A == 2)
                [num,txt,raw] = xlsread(fname);
                rawSize = size(raw);
                numrows = rawSize(1);
                numcols = rawSize(2);
                if (numcols == 10)
                    outp = blankTemplate;
                    for i=1:(numrows-2)
                        for j=1:9
                            outp{(i+1),j} = num(i,j);
                        end
                        outp{(i+1),10} = txt{(i+1),10};
                    end
                    outp{(numrows),1} = ' ';
                    exmsg  = ['You have imported ' fname];
                    displayMatrix(outp);
                    h = msgbox(exmsg);
                else
                    exmsg  = [fname ' does not have appropriate dimensions'];
                    h = msgbox(exmsg);
                end
            else
                exmsg  = [fname ' does not exist in the current path'];
                h = msgbox(exmsg);
            end
        end
    elseif(isempty(y))
        h = msgbox('Not a valid input');
   
    elseif(y >= 1 && y <= numberOfCurves) %analyze a curve
        
        %values accessed by (row, column)
        mCurve = [mData(:,1), mData(:, y + 1)];  % make a curve with all of the rows in the first column = x, all rows in curveNum column = y
        f1 = figure(1); %figure 1
        set(f1, 'Position', [500 50 600 370]);
        plot(mCurve(:,1), mCurve(:,2)); %plot all values in first curve column = x, all values in second curve column = y.
        grid on;
        title([mCurveType, ' curve ', num2str(curveNum)]);
        xlabel('Time (min)');
        ylabel(strcat(mCurveType, ' Ratio'));
        %ylabel('%s Ratio', mCurveType);
        
        if(analyzeThisCurve(mCurve)) %ask user input in analyzeThisCurve
            %check range->newCurve
            
            rangeStart = input('Enter starting point (default = 1): ');
            rangeEnd = input('Enter end point: ');
            if (isempty(rangeStart))
                rangeStart = 1;
            else
                mCurveXs = mCurve(:, 1);
                i = 2;
                while (mCurveXs(i) < rangeStart)
                    i = i + 1;
                end
                rangeStart = i;
%                 mCurveXs = mCurve(:, 1);
%                 rangeStart = find(mCurveXs == rangeStart);
            end
            if (isempty(rangeEnd))
                rangeEnd = length(mCurve);
            else
                mCurveXs = mCurve(:, 1);
                i = 1;
                while (mCurveXs(i) < rangeEnd)
                    i = i + 1;
                end
                rangeEnd = i;
            end
            
            mCurve = [mData(rangeStart:rangeEnd, 1), mData(rangeStart:rangeEnd, y+1)];
            % spit out average y value for the curve
            
            mCurveYs = mCurve(:, 2);
            avgY = mean(mCurveYs);
            expoSize = length(outp(:,1));

%             outp{expoSize, 11} = avgY;
%             outp{expoSize, 1} = y;
            
            outp{expoSize, 13} = avgY;
            outp{expoSize, 1} = y;
            
            if (exist('dData', 'var'))
                dCurve = [dData(rangeStart:rangeEnd, 1), dData(rangeStart:rangeEnd, y+1)];
            end
            
            if(nargin == 1)
                analyzeSpikes(mCurve, mCurveType, y);
            else
                analyzeSpikes(mCurve, mCurveType, y, dCurve, dCurveType);
            end
            
        end
    else
        h = msgbox('Not a valid input');
    end
end
