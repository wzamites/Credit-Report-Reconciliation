# Credit-Report-Reconciliation
Learn the differences between three reports with a GUI

This project is to take poorly formatted reports in .csv and easily show the differences
between the three lists. These are lists of daily transactions run through a cash register
and each day it's necessary to be sure that the report from the credit card company 
matches the two reports from the register software. I'm only interested in credit card 
transactions (Visa, Mastercard, etc) and not other forms of payment (cash, etc).

The idea is to list every unique transaction. Then, in three columns representing each
report appears a logical 1 or a 0 of whether that transaction appears in that report. 
For example, 1/1/1 in a row would indicate that all reports show that transaction.


I started this project and compiled a stand-alone windows application using MATLAB.

ReconsileCreditTest2.m:
is used to test what would happen
when the "save as..." button is clicked in the gui without actually running the interface.

ReconsileCredit.m:
This is connected to the UI that asks for the three files for comparison. It has an import
button where you can select the three files. The script then figures out which is which
and runs the data mining when the user clicks "save as..."

ReconsileCredit.fig:
This is the figure representing the user interface, and runs when the application is launched.
Its buttons execute the script

Read.py:
The goal here is the same as always, although I'd like to find a way to have the user drag the
three files (either separately or all at once) over the UI window, then have the code automatically
execute once the three separate files have been pointed to. This would reduce the number of clicks
by about 15 since the original version, since it wouldn't be necessary to point to each separate
file individually.