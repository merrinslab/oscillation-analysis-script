# oscillation-analysis-script
script for analysis of islet oscillations
Oscillation analysis script instructions
Importing files into Matlab:
1.	Open Matlab.
2.	Navigate to data (should be formatted with time as the first column and y-values as following columns)
3.	Import data as a numeric matrix.
4.	If analyzing more than one sensor at a time, repeat for relevant sensors.  Note: script can handle a maximum two simultaneous sensors at a time and currently supports Calcium, ATP/ADP, and Lactate oscillations.
Analyzing oscillations:
1.	In Matlab, navigate to analysis script
2.	Enter analyzeData(yourDataHere) in the command line to run script. 
3.	Answer the prompt about which curve to analyze (e.g., type “1” into the command prompt, then press Enter.)
4.	The trace will pop up in a window.  Decide if you want to include this trace in the analysis and then type “y” for Yes and “n” for No.  Press Enter.
5.	The “starting point” refers to the time at which the analysis begins (helpful for excluding ugly starts to runs).  Default is the beginning of the trace.  Enter a number, then press enter; or press Enter to use the default.
6.	“end point” default is the end of the run.  Enter a number, then press enter; or press Enter to use the default.  Helpful for excluding different conditions, etc.
7.	The “spike threshold” refers to the amplitude threshold that defines a peak- smaller spike threshold = more subtle (smaller) peaks.  You can change this number after this step if it doesn’t work.  Enter a number and press Enter, or just press Enter to use the default.
8.	Another graph will pop up- green asterisks are what the script has identified as the troughs and red asterisks are peaks.  From here you have three options:
1-	Adjust (sensor) Threshold: allows you to modify the spike threshold if the current value doesn’t work.
2-	Detrend (sensor) Curve: If the spike threshold looks okay, then move on to this step.  It is essential you do this before moving on to 3!  The script will break if you do not do this before 3!   This removes any orphan peaks- peaks without two troughs that defines a complete oscillation. When you do this, a larger window pops up. Click anywhere outside the graph portion within the window. It is essential that you click outside the graph either to the right or the left for correct detrending!
3-	Investigate (sensor) Plateau Fraction: If the spike threshold looks good and you’ve detrended your trace, this will actually do all the calculations.  Another graph will pop up with the plateau fraction illustrated.  Answer “y” to the prompt to save the results.  Results are temporarily stored in a table in a variable called “outp.mat.”
9.	If you are happy with the results from this curve, answer “q” to return to the other traces.  The table of results pops up in another window, but don’t worry about copying/moving data.  It’s still stored in oupt.mat.
10.	Analyze as many traces as needed, repeating steps 3-9.
11.	When you have no more curves, press “q” to end the session.  It will ask if you want to save the results to a separate excel sheet.  If you do this, the content of outp.mat is saved in an excel sheet in the same folder as the script.  If you do not do this, all of the oupt.mat content will be saved after the script finishes if you wish to copy it to another document.

