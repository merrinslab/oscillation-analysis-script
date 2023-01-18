function [pArea] = perplatarea(baseheight,platheight,troughs,peaks,curve)

pArea = [];
pSize = size(peaks);
pSize = pSize(1);

for pulse=1:pSize
    tmp = abs(curve(:,1)-troughs(pulse,1));
    [ida ida] = min(tmp);
    tmp = abs(curve(:,1)-troughs((pulse+1),1));
    [idc idc] = min(tmp);
    tmp = abs(curve(:,1)-peaks(pulse,1));
    [idb idb] = min(tmp);

    y1 = baseheight(pulse);
    y2 = [];

    %find the index (x value) where active phase begins - the peak.
    lbound = find(curve(:,1) == peaks(pulse, 1));

    %find the index (x value) where pulse ends- where curve dips below
    %baseheight
        
    for i=idb:idc
        if (curve(i,2) < y1)
            break
        end
    end
    rbound = i;

    xscale = curve(lbound:rbound,1); % the x values of the pulse
    y2 = curve(lbound:rbound,2); % the y values of the pulse

    
    %instead of making y values all the way up to peak, plateau it off when
    %y values are greater than platheight
%     for i=1:length(y2) 
%         if (y2(i) > platheight(pulse))
%             y2(i) = platheight(pulse);
%         end
%     end

    area(xscale,y2,y1);
    colormap cool;
    
    yv = [baseheight(pulse); y2; baseheight(pulse); baseheight(pulse)];
    xv = [xscale(1); xscale; xscale(end); xscale(1)];
    pArea(pulse) = polyarea(xv,yv);
end

