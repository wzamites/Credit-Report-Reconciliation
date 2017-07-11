function SaveAs_Callback(hObject, eventdata, handles)
%% Get the paths of the three files with some error messages
[filenames,pathname,Check]=uigetfile('*.csv','Select the Three Files',...
    'MultiSelect', 'on');

if Check == 0
return;
end

if length(filenames) ~= 3;
    errordlg('Use the Shift key to select the three files',...
        'Three (3) Files Not Selected');
    return;
end

clear Check
%% Import all these into a cell arrays and identify them

for j = 1:3

fid2 = fopen(sprintf('%s%s',pathname,filenames{j}), 'rt'); 
count = 0;
oneline = fgets(fid2);

a = cell(10000,1);
while ischar(oneline)
    count = count + 1;
     a{count} = oneline;
    oneline = fgets(fid2);
end
fclose(fid2);

for i = 10000:-1:count+1
    a(i,:) = [];
end

% Now identify it

if strcmp(a{1}(1:21),' ,     Account Number')
    CC = a; %since that's CC report

elseif strcmp(a{1}(1:20),' ,     Tender Amount')
    TL = a; %since that's the Tender Listing Report

elseif strcmp(a{1}(1:12),'Merchant DBA')
    pathnameV = pathname;
    filenameV = filenames{j};

else
    message1 = sprintf(...
        'There is a problem with the file %s. Make sure... it''s formatted correctly.'...
        ,filenames{j});
    errordlg(message1,'Problem with file');
    return;
end

clear ans count fid2 i oneline a

end
clear j
%% This extracts the data in CC listing and makes a 6 column thing

CCreport = cell(length(CC),6);
count = 0;

%find what line the thing really starts on
for start = 1:10
    if strcmp(CC{2}(start:start+1),'  ');
        break;
    end
end

%for every line in the text file...
for ii = 3:length(CC)
    
    %get the card type at the top. Other ifs will fail until the next ii
    if ~strcmp(CC{ii}(start),' ');
        cardtype = strtrim(CC{ii}(start:100));
    end
    
    %this is supposed to identify lines with the data on it
    %if yes, it will always come after the card type line.
    if strcmp(CC{ii}(start+75),'0');
        count = count+1;
        thedate = strtrim(CC{ii}(start+56:start+65));
        theprice = strrep(strtrim(CC{ii}(start+42:start+53)),',','');
        accountnum = CC{ii}(start+5:start+20);
        registernum = CC{ii}(start+78);
        transnum = CC{ii}(start+84:start+87);
        
        CCreport{count,1} = thedate;
        CCreport{count,2} = cardtype;
        CCreport{count,3} = theprice;
        CCreport{count,4} = accountnum;
        CCreport{count,5} = registernum;
        CCreport{count,6} = transnum;
    end
end

%gets rid of the empty space at the end
b = length(CCreport); 
for i = b:-1:count+1
    CCreport(i,:) = [];
end

clear accountnum cardtype count i ii registernum start theprice...
    transnum b pathname a2

%% This makes the CC Cell Array (CCoriginal) it into strings
% This is necessary to check for duplicates as far as I know.

%%% do this in-place
for vvv = 1:length(CCreport)
CCreport{vvv,1} = sprintf('%s %s %s %s %s %s',CCreport{vvv,1},...
    CCreport{vvv,2},CCreport{vvv,3},CCreport{vvv,4},...
    CCreport{vvv,5},CCreport{vvv,6});
end

%delete the columns
for i = 1:5
CCreport(:,2) = [];
end

CCreport = sort(unique(CCreport,'stable'));

clear i vvv
%% The next two extracts the TLR into a cell array 6 columns (TLRnew)
%find what line the thing really starts on to circumvent formatting changes
for start = 1:10
    if strcmp(TL{2}(start:start+1),'  ');
        break;
    end
end

count1 = 0;
transtype = 0;
TLRreport = cell(length(TL),6);

for i = 1:length(TL)         %go line by line on cell array 'a1'
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %this if statement grabs the transaction type
    if ~strcmp(TL{i}(start),' ')
        transtype = strtrim(TL{i}(start:start+100));
    end
    
    %if the transtype is not a credit card company, go to the next line
    if ~strcmp(transtype,'AMEX') && ~strcmp(transtype,'MASTERCARD')...
            && ~strcmp(transtype,'DISCOVER') && ~strcmp(transtype,'VISA')
        continue;
    end
    
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %this if identifies a row of a transaction
    if TL{i}(start+79) == '0';
        count1 = count1+1;
        
        amount = strtrim(strrep(TL{i}(start:start+14),',',''));
        acctnumber = strtrim(TL{i}(start+24:start+44));
        regnum = TL{i}(start+82);
        transnum = TL{i}(start+94:start+97);

        TLRreport{count1,1} = thedate;
        TLRreport{count1,2} = transtype;
        TLRreport{count1,3} = amount;
        TLRreport{count1,4} = acctnumber;
        TLRreport{count1,5} = regnum;
        TLRreport{count1,6} = transnum;
    end
end
%This deletes the empty cells on the bottom
for i = length(TLRreport):-1:count1+1
    TLRreport(i,:) = [];
end



clear a1 acctnumber amount count1 i regnum start transnum transtype
%% This puts the TLR into strings

TLRstrings = cell(length(TLRreport),1);

for i = 1:length(TLRreport)
    TLRstrings{i,1} = sprintf('%s %s %s %s %s %s',...
        TLRreport{i,1},TLRreport{i,2},TLRreport{i,3},TLRreport{i,4},...
        TLRreport{i,5},TLRreport{i,6});
end
clear i TLRreport
%% Make Combines the two
combine = unique([CCreport; TLRstrings]);
%% Makes the cell array for the final chart

%Five columns bc column 2 is to separate the trasnaction number out
% so column 1 is date - transnum, column 2 is transnum, and 3,4,5 are
% booloeans

finalchart = cell(length(combine),9);

% add combine to the first column
for i = 1:length(finalchart)
    finalchart(i,1) = combine(i);
end
clear i

%second column is the TLR

for ii = 1:length(finalchart)
    if any(strcmp(TLRstrings,finalchart{ii,1}))
        finalchart{ii,7} = 1;
    else
        finalchart{ii,7} = 0;
    end
end
clear ii

%Third column is the CCTLR
for ii = 1:length(finalchart)
    if any(strcmp(CCreport,finalchart{ii,1}))
        finalchart{ii,8} = 1;
    else
        finalchart{ii,8} = 0;
    end
end
clear ii

%% Editing the finalchart to get the transaction number its own column

for ii = 1:length(finalchart)
    finalchart{ii,6} = finalchart{ii,1}(length(finalchart{ii,1})-...
        3:length(finalchart{ii,1}));
    finalchart{ii,1} = finalchart{ii,1}(1:length(finalchart{ii,1})-5);
end
clear ii
%% Initialize variables.
% pathnameV = handles.pathnameV;
% filenameV = handles.filenameV;

filenames = sprintf('%s%s',pathnameV,filenameV);
delimiter = ',';
fid2 = fopen(sprintf('%s',filenames), 'rt'); 
oneline = fgets(fid2);
fclose(fid2);
numbercolumns = length(strfind(oneline,','))+1;
clear fid2 count oneline

%% Format string for each line of text:
strings = cell(1,numbercolumns);
for i = 1:numbercolumns
    strings{1,i} = '%s';
end    
formatSpec = sprintf('%s%s',strjoin(strings,''),'%[^\n\r]');

clear strings numbercolumns i
%% Open the text file.
fileID = fopen(filenames,'r');
%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
    'ReturnOnError', false);
%% Close the text file.
fclose(fileID);
%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.
%% Create output variable
outputvariable = [dataArray{1:end-1}];
%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;
%% Fix the headers
[~,width] = size(outputvariable);
for i = 1:width
    if strcmp(outputvariable{1,i},'CardLogo')
        CardTypeColumn = i;
        break
    end
end

for i = 1:width
    if strcmp(outputvariable{1,i},'ApprovedAmount')
        AmountColumn = i;
        break
    end
end

for i = 1:width
    if strcmp(outputvariable{1,i},'CardNumberMasked')
        CardNumberColumn = i;
        break
    end
end

for i = 1:width
    if strcmp(outputvariable{1,i},'LaneNumber')
        RegisterColumn = i;
        break
    end
end

for i = 1:width
    if strcmp(outputvariable{1,i},'TransactionAmount')
        TransactionAmountColumn = i;
        break
    end
end

for i = 1:width
    if strcmp(outputvariable{1,i},'TransactionType')
        TransactionTypeColumn = i;
        break
    end
end
clear i clear width
%% Replace the blanks with negative return amounts

for i = 1:length(outputvariable)
    if strcmp(outputvariable{i,TransactionTypeColumn},'CreditCardReturn') ||...
            strcmp(outputvariable{i,TransactionTypeColumn},'CreditCardCredit')
        outputvariable{i,AmountColumn} =...
            num2str(str2double(outputvariable{i,TransactionAmountColumn}) * -1);
    end
end
%% Delete dashes, capitalize everything, take out commas in one pump
for i = 1:length(outputvariable)
outputvariable{i,CardNumberColumn} = strrep(outputvariable{i,CardNumberColumn},'-','');
outputvariable{i,CardNumberColumn} = upper(outputvariable{i,CardNumberColumn});
outputvariable{i,CardTypeColumn} = upper(outputvariable{i,CardTypeColumn});
end
%% Construct a list of transactions

vtranslist = cell(length(outputvariable) - 1,1);

for i = 2:length(outputvariable)
vtranslist{i-1,1} = sprintf('%s %s %.2f %s %s',...
    thedate,...
    outputvariable{i,CardTypeColumn},...
    str2double(outputvariable{i,AmountColumn}),...
    outputvariable{i,CardNumberColumn},...
    outputvariable{i,RegisterColumn});
end
clear i
%% Clear temporary variables
clearvars i filename delimiter formatSpec fileID dataArray ans raw col...
    numericData rawData row regexstr result numbers...
    invalidThousandsSeparator thousandsRegExp me rawNumericColumns...
    rawCellColumns R AmountColumn CardNumberColumn CardTypeColumn...
    RegisterColumn TransactionAmountColumn TransactionTypeColumn...
    filenames filenameV outputvariable pathnameV
%% Adding to the end of finalchart if there are any vantiv transactions...
%that weren't in tender listing THIS ONLY ADD SHIT AT THE END

a = length(vtranslist);
for ii = 1:a
    b = any(strcmp(vtranslist{ii},finalchart));
        if b(1) == 0
            finalchart{length(finalchart)+1,1} = vtranslist{ii};
            finalchart{length(finalchart),7} = 0;
            finalchart{length(finalchart),8} = 0;
        end
end
 clear ii b a
%% Now go through the vantiv list and makes ones and zeros

a = length(finalchart);
for ii = 1:a
    if any(strcmp(finalchart{ii,1},vtranslist));
        finalchart{ii,9} = 1;
    else
        finalchart{ii,9} = 0;
    end
end
clear ii b a
%% Clear all the stuff except for what you need

clear CCoriginal CCstrings combine12 CCoriginal TLRnew TLRstrings...
    vtranslist wholestrings

%% Separate this cell array out for xlswrite


for i = 1:length(finalchart)
spacepositions = strfind(finalchart{i,1},' ');
finalchart{i,6} = str2double(finalchart(i,6));
finalchart{i,5} = finalchart{i,1}(spacepositions(4) + 1);
finalchart{i,4} = finalchart{i,1}(spacepositions(3)+1:spacepositions(4)-1);
finalchart{i,3} = finalchart{i,1}(spacepositions(2)+1:spacepositions(3)-1);
finalchart{i,2} = finalchart{i,1}(spacepositions(1)+1:spacepositions(2)-1);
finalchart{i,1} = finalchart{i,1}(1:spacepositions(1)-1);
end

finalchart = sortrows(finalchart,6);

header = cell(1,9);
header{1,1} = 'Date';
header{1,2} = 'Card Type';
header{1,3} = 'Amount';
header{1,4} = 'Card Number';
header{1,5} = 'Register Number';
header{1,6} = 'Transaction Number';
header{1,7} = 'Tender Listing';
header{1,8} = 'Credit Card';
header{1,9} = 'Vantiv';

Reconcile = sprintf('Reconcile (%s).xlsx', strrep(thedate,'/','-'));
[filenameR,pathR] = uiputfile(Reconcile,'Save Reconcile As');
Reconcile = sprintf('%s%s',pathR,filenameR);

xlswrite(Reconcile,header,1,'A1');
xlswrite(Reconcile,finalchart,1,'A2');

clear CCreport combine filenameR finalchart header i pathR Reconcile...
    spacepositions thedate;
end