function [newpeaks, newtroughs, newcurve, idb] = flatten(peaks, troughs, curve)

%takes a curve and performs a linear detrend.  User inputs the portion of
%the curve to fit the line.

%clear
%load('expoints58.mat');
f2 = figure(2);
set(f2, 'Position', [100 60 1100 650]);

[xi,yi,but] = ginput(1);

tmp = abs(troughs(:,1)-xi);
[idb idb] = min(tmp);
tmp = abs(curve(:,1)-xi);
[idc idc] = min(tmp);

if (idb==length(troughs))
    idb = 1;
end

if ((but==3) || (idb==1))
    parameters = polyfit(troughs(:,1), troughs(:,2), 1);
    cline = parameters(1).*curve(:,1);
    pline = parameters(1).*peaks(:,1);
    tline = parameters(1).*troughs(:,1);
    
    newcurve = [curve(:,1), curve(:,2) - cline];
    newpeaks = [peaks(:,1), peaks(:,2) - pline];
    newtroughs = [troughs(:,1), troughs(:,2) - tline];
    
    figure(1);
    hold on
    plot(curve(:,1), cline + parameters(2))
    hold off
else
    parameters = polyfit(troughs(1:idb,1), troughs(1:idb,2), 1);
    h1 = parameters(2);
    cline1 = parameters(1).*curve(1:idc,1);
    pline = parameters(1).*peaks(1:(idb-1),1);
    tline = parameters(1).*troughs(1:idb,1);
    parameters = polyfit(troughs((idb+1):end,1), troughs((idb+1):end,2), 1);
    cline2 = parameters(1).*curve((idc+1):end,1);
    pline = [pline; parameters(1).*peaks(idb:end,1)];
    tline = [tline; parameters(1).*troughs((idb+1):end,1)];
    cline = [cline1; cline2];

    newcurve = [curve(:,1), curve(:,2) - cline];
    newpeaks = [peaks(:,1), peaks(:,2) - pline];
    newtroughs = [troughs(:,1), troughs(:,2) - tline];
    amp_before = (peaks(idb,2) - troughs(idb,2));
    amp_after = (newpeaks(idb,2) - newtroughs(idb,2));
    deltaY = (amp_after - amp_before);

    newcurve(1:idc,2) = newcurve(1:idc,2) + deltaY*.5;
    newcurve((idc+1):end,2) = newcurve((idc+1):end,2) - deltaY*.5;
    newpeaks(1:(idb-1),2) = newpeaks(1:(idb-1),2) + deltaY*.5;
    newpeaks(idb:end,2) = newpeaks(idb:end,2) - deltaY*.5;
    newtroughs(1:idb,2) = newtroughs(1:idb,2) + deltaY*.5;
    newtroughs((idb+1):end,2) = newtroughs((idb+1):end,2) - deltaY*.5;

    figure(1)
    hold on
    plot(curve(1:idc,1), cline1 + h1)
    plot(curve((idc+1):end,1), cline2 + parameters(2))
    hold off
end

f2 = figure(2);
clf;
set(f2, 'Position', [660 50 600 370]);
plot(newcurve(:,1),newcurve(:,2))
grid on


% THIS WILL SAVE YOUR DATA POINTS!!
c = clock;
if (c(5) < 10)
    minute = [num2str(0) num2str(c(5))];
else
    minute = num2str(c(5));
end
point_fname = ['pointData_' num2str(c(4)) minute '.mat'];
save(point_fname,'peaks','troughs','curve');


