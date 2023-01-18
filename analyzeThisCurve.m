function [analyzeIt] = analyzeThisCurve(curve)
%EFF: returns true if user wants to analyze it.  otherwise returns false.

while(true)
    x = input('Do you want to analyze this curve? (y/n) ', 's');
    if(x == 'y')
        analyzeIt = true;
        return;
    end
    if(x == 'n')
        analyzeIt = false;
        return;
    end
    disp('Not a valid input')
end