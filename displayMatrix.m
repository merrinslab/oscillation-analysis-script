function displayMatrix(outSet)

f3 = figure(3);
set(f3, 'Position', [420 100 810 250]);
clf
t = uitable('Parent', f3, 'Position', [20 20 770 220]);
set(t, 'ColumnName', outSet(1,:));
set(t, 'Data', outSet(2:(end-1),:));
set(t, 'RowName', []);