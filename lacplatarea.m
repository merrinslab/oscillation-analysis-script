function [pArea] = lacplatarea(peakheight,platheight,troughs,peaks,curve)

platheight = platheight(1, 2:end);
pArea = [];
pSize = size(peaks);
pSize = pSize(1);

for pulse=1:pSize-1
    tmp = abs(curve(:,1)-peaks(pulse,1));
    [ida ida] = min(tmp);
    tmp = abs(curve(:,1)-peaks((pulse+1),1));
    [idc idc] = min(tmp);
    tmp = abs(curve(:,1)-troughs(pulse+1,1));
    [idb idb] = min(tmp);

    y1 = peakheight(pulse);
    y2 = [];

    %find index where pulse begins - where y values above peakheight
%     for i=idb:-1:ida
%         if (curve(i,2) > y1)
%             break
%         end
%     end
%     lbound = i+1;

    lbound = find(curve(:,1) == troughs(pulse, 1));

    %find index where pulse ends - where y values above peakheight
    for i=idb:idc
        if (curve(i,2) > y1)
            break
        end
    end
    rbound = i;

    xscale = curve(lbound:rbound,1);
    y2 = curve(lbound:rbound,2);

    %cut plateau off- if y <plateau height, y = platheight
%     for i=1:length(y2)
%         if (y2(i) < platheight(pulse))
%             y2(i) = platheight(pulse);
%         end
%     end

    area(xscale,y2,y1);
    colormap cool;
    
    yv = [baseheight(pulse); y2; baseheight(pulse); baseheight(pulse)];
    xv = [xscale(1); xscale; xscale(end); xscale(1)];
    pArea(pulse) = polyarea(xv,yv);
end

