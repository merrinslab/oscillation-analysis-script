function [maxtab, mintab]=peakdetect(v, delta, x)
%PEAKDET Detect peaks in a vector
%        [MAXTAB, MINTAB] = PEAKDET(V, DELTA) finds the local
%        maxima and minima ("peaks") in the vector V.
%        MAXTAB and MINTAB consists of two columns. Column 1
%        contains indices in V, and column 2 the found values.
%      
%        With [MAXTAB, MINTAB] = PEAKDET(V, DELTA, X) the indices
%        in MAXTAB and MINTAB are replaced with the corresponding
%        X-values.
%
%        A point is considered a maximum peak if it has the maximal
%        value, and was preceded (to the left) by a value lower by
%        DELTA.

maxtab = [];
mintab = [];

v = v(:); % Just in case this wasn't a proper vector

if nargin < 3
  x = (1:length(v))';
else 
  x = x(:);
  if length(v)~= length(x)
    error('Input vectors v and x must have same length');
  end
end
  
if (length(delta(:)))>1
  error('Input argument DELTA must be a scalar');
end

if delta <= 0
  error('Input argument DELTA must be positive');
end

mn = Inf; mx = -Inf;
mnpos = NaN; mxpos = NaN;

% delta === "significantly"
% mx = max to beat
% mn = min to beat
lookformax = 1; %look for maximums first

for i=1:length(v)
  this = v(i);
  if this > mx, mx = this; mxpos = x(i); end % if we're (still) going up, assign this as mx (the mx point to beat)
  if this < mn, mn = this; mnpos = x(i); end % if we're (still) going down, assign this as mn (the mn point to beat)
  
  if lookformax %if looking for maximums
    if this < mx-delta  % only if we're significantly lower than mx- we beat it
      maxtab = [maxtab ; mxpos mx]; %then assign mx as a "maximum"
      mn = this; mnpos = x(i); %then assign this as mn (the new mn point to beat)
      lookformax = 0; %now start looking for minimums.
    end  
  else % if looking for minimums
    if this > mn+delta % only if we're significantly higher than mn- we beat it
     % mintab = [mintab ; mnpos mn]; % then assign mn as a "minimum"
      mx = this; mxpos = x(i); % then assign this as mx- the new mx point to beat
      %lookformax = 1; %now start looking for maximums.
      ii = 1;
      for ii=1:length(v)
          if lookformax == 0
              currentpos = i-ii;
              current = v(currentpos);
              if current < v(currentpos+1) %& current > mn+delta   %if we're going down and there isn't a huge jump to mn
                  mn = current; mnpos = x(currentpos);
              else
                  mintab = [mintab ; mnpos mn];
                  lookformax = 1;
              end
          end
      end
    end
  end
end
