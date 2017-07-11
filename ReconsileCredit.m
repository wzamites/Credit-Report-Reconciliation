function varargout = ReconsileCredit(varargin)
% RECONSILECREDIT MATLAB code for ReconsileCredit.fig
%      RECONSILECREDIT, by itself, creates a new RECONSILECREDIT or raises the existing
%      singleton*.
%
%      H = RECONSILECREDIT returns the handle to a new RECONSILECREDIT or the handle to
%      the existing singleton*.
%
%      RECONSILECREDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECONSILECREDIT.M with the given input arguments.
%
%      RECONSILECREDIT('Property','Value',...) creates a new RECONSILECREDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReconsileCredit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReconsileCredit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReconsileCredit

% Last Modified by GUIDE v2.5 25-May-2017 13:15:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ReconsileCredit_OpeningFcn, ...
                   'gui_OutputFcn',  @ReconsileCredit_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ReconsileCredit is made visible.
function ReconsileCredit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReconsileCredit (see VARARGIN)

% Choose default command line output for ReconsileCredit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ReconsileCredit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReconsileCredit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SaveAs.
function SaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'filenameCC') && isfield(handles,'filenameV') &&...
        isfield(handles,'TLfilename')
%% Puts the CCTender Listing to cell array "a2"

pathnameCC = handles.pathnameCC;
filenameCC = handles.filenameCC;

fid2 = fopen(sprintf('%s%s',pathnameCC,filenameCC), 'rt'); 
count = 0;
oneline = fgets(fid2);

a2 = cell(2500,1);
while ischar(oneline)
    count = count + 1;
     a2{count} = oneline;
    oneline = fgets(fid2);
end
fclose(fid2);

for i = 2500:-1:count+1
    a2(i,:) = [];
end


clear fid2 pathnameCC filenameCC oneline ans
%% This extracts the data and makes a 6 column thing

CCoriginal = cell(count,6);
count = 0;
for ii = 1:length(a2)
    if a2{ii}(6) ~= ' ';
        for iii = 6:20
            if a2{ii}(iii) == ' ';
                typelength = iii - 1;
                cardtype = a2{ii}(6:typelength);
                break
            end
        end
    end
    
    if a2{ii}(81) == '0'
        thedate = a2{ii}(62:71);
        for vv = 48:59;
            if a2{ii}(vv) ~= ' '
                pricelength = vv;
                theprice = strrep(a2{ii}(pricelength:59),',','');
                break
            end
        end
        count = count + 1;
        CCoriginal{count,1} = thedate;
        CCoriginal{count,2} = cardtype;
        CCoriginal{count,3} = theprice;
        CCoriginal{count,4} = a2{ii}(11:26);
        CCoriginal{count,5} = a2{ii}(84);
        CCoriginal{count,6} = a2{ii}(90:93);        
    end
end

b = length(CCoriginal); %gotta get the count at this point
for i = b:-1:count+1
    CCoriginal(i,:) = [];
end

clear count ii a2 iii typelength cardtype vv pricelength...
    theprice emptyCells i b
%% This makes the CC Cell Array (CCoriginal) it into strings

%%% do this in-place
for vvv = 1:length(CCoriginal)
CCoriginal{vvv,1} = sprintf('%s\t%s\t%s\t%s\t%s\t%s',CCoriginal{vvv,1},...
    CCoriginal{vvv,2},CCoriginal{vvv,3},CCoriginal{vvv,4},...
    CCoriginal{vvv,5},CCoriginal{vvv,6});
end

for i = 1:5
CCoriginal(:,2) = [];
end

CCoriginal = sort(unique(CCoriginal,'stable'));

clear i vvv
    %% Import the Tender Listing Report to a1

TLpathname = handles.TLpathname;
TLfilename = handles.TLfilename;
fid1 = fopen(sprintf('%s%s',TLpathname,TLfilename), 'rt'); 
count = 0;
oneline = fgets(fid1);

%we get it in there and it comes in as the cell array 'a1'

a1 = cell(2000,1);
    while ischar(oneline)
        count = count+1;
        a1{count} = oneline;
        oneline = fgets(fid1);
    end
fclose(fid1);

for i = 2000:-1:count+1
    a1(i,:) = [];
end


clear fid1 count TLpathname TLfilename online
%% The next two extracts the TLR into a cell array 6 columns (TLRnew)
%% Do this one ONLY if it's formatted with common decency
if strcmp(a1{2}(1:5),'" ","')
count1 = 0;
transtype = 0;
for i = 1:length(a1)         %go line by line on cell array 'a1'
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %this if statement grabs the transaction type
    if a1{i}(6) ~= ' '   
    for j = 6:30
        if a1{i}(j:j+1) == '  '
            transtype = a1{i}(6:j-1);
            break
        end
    end
    end
    
    if ~strcmp(transtype,'AMEX') && ~strcmp(transtype,'MASTERCARD')...
            && ~strcmp(transtype,'DISCOVER') && ~strcmp(transtype,'VISA')
        continue;
    end
    
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    if a1{i}(85) == '0';
        count1 = count1+1;
        TLRnew{count1,2} = transtype;
        
        for ii = 6:20;
            if a1{i}(ii) ~= ' '
                break
            end
        end
        
        amount = strrep(a1{i}(ii:20),',','');
        TLRnew{count1,3} = amount;
        
        for iii = 30:61
            if a1{i}(iii) == ' '
                index1 = iii-1;
                break
            end
        end
        acctnumber = a1{i}(30:index1);
        TLRnew{count1,4} = acctnumber;
        
        regnum = a1{i}(88);
        TLRnew{count1,5} = regnum;
        
        transnum = a1{i}(100:103);
        TLRnew{count1,6} = transnum;
        TLRnew{count1,1} = thedate;
    end
end
end

%% if TLR's formatted like a hot steaming pile of garbage then do this
if strcmp(a1{2}(1:2),' ,')
count1 = 0;
transtype = 0;
for i = 1:length(a1)         %go line by line on cell array 'a1'
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %this if statement grabs the transaction type
    if a1{i}(4) ~= ' '   
    for j = 3:26
        if a1{i}(j:j+1) == '  '
            transtype = a1{i}(3:j-1);
            break
        end
    end
    end
    
    if ~strcmp(transtype,'AMEX') && ~strcmp(transtype,'MASTERCARD')...
            && ~strcmp(transtype,'DISCOVER') && ~strcmp(transtype,'VISA')
        continue;
    end
    
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    if a1{i}(82) == '0';
        count1 = count1+1;
        TLRnew{count1,2} = transtype;
        
        for ii = 3:17;
            if a1{i}(ii) ~= ' '
                break
            end
        end
        
        amount = strrep(a1{i}(ii:17),',','');
        TLRnew{count1,3} = amount;
        
        for iii = 27:61
            if a1{i}(iii) == ' '
                index1 = iii-1;
                break
            end
        end
        acctnumber = a1{i}(27:index1);
        TLRnew{count1,4} = acctnumber;
        
        regnum = a1{i}(85);
        TLRnew{count1,5} = regnum;
        
        transnum = a1{i}(97:100);
        TLRnew{count1,6} = transnum;
        TLRnew{count1,1} = thedate;
    end
end
end

%% clear the variables either way
clear transnum regnum acctnumber index1 a1 count1 transtype j i ii iii
%% This puts the TLR into strings PLUS the thing at the end

TLRstrings = cell(length(TLRnew),1);

for iiv = 1:length(TLRnew)
    TLRstrings{iiv,1} = sprintf('%s\t%s\t%s\t%s\t%s\t%s',...
        TLRnew{iiv,1},TLRnew{iiv,2},TLRnew{iiv,3},TLRnew{iiv,4},...
        TLRnew{iiv,5},TLRnew{iiv,6});
end
clear iiv TLRnew
%% Make Combine12
combine12 = unique([CCoriginal; TLRstrings]);
%% Makes the cell array for the final chart

%This is five columns bc column2 is to separate the trasnaction number out
finalchart = cell(length(combine12),5);

for i = 1:length(combine12)
    finalchart{i,1} = strrep(combine12{i},',',''); 
    %put it in there and also get rid of the comma if there is one
end
clear i

%second column is the TLR

for ii = 1:length(finalchart)
if any(strcmp(TLRstrings,finalchart{ii,1}))
    finalchart{ii,3} = 1;
else
    finalchart{ii,3} = 0;
end
end
clear ii

%Third column is the CCTLR
for ii = 1:length(finalchart)
if any(strcmp(CCoriginal,finalchart{ii,1}))
    finalchart{ii,4} = 1;
else
    finalchart{ii,4} = 0;
end
end
clear ii

%% Editing the finalchart to get the transaction number its own column

for ii = 1:length(finalchart)
    finalchart{ii,2} = finalchart{ii,1}(length(finalchart{ii,1})-...
        3:length(finalchart{ii,1}));
    finalchart{ii,1} = finalchart{ii,1}(1:length(finalchart{ii,1})-5);
end
clear ii
%% Initialize variables.
pathnameV = handles.pathnameV;
filenameV = handles.filenameV;

filename = sprintf('%s%s',pathnameV,filenameV);
delimiter = ',';
fid2 = fopen(sprintf('%s',filename), 'rt'); 
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
fileID = fopen(filename,'r');
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
%% Fix the God Damn headers
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
vtranslist{i-1,1} = sprintf('%s\t%s\t%.2f\t%s\t%s',...
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
    rawCellColumns R;
%% Adding to the end of finalchart if there are any vantiv transactions...
%that weren't in tender listing

a = length(vtranslist);
for ii = 1:a
    b = any(strcmp(vtranslist{ii},finalchart));
        if b(1) == 0
            finalchart{length(finalchart)+1,1} = vtranslist{ii};
            finalchart{length(finalchart),3} = 0;
            finalchart{length(finalchart),4} = 0;
        end
end
 clear ii b a
%% Now go through the vantiv list and makes ones and zeros

a = length(finalchart);
for ii = 1:a
    if any(strcmp(finalchart{ii,1},vtranslist));
        finalchart{ii,5} = 1;
    else
        finalchart{ii,5} = 0;
    end
end
clear ii b a
%% Clear all the stuff except for what you need

clear CCoriginal CCstrings combine12 CCoriginal TLRnew TLRstrings...
    vtranslist wholestrings
%% Make this new file called CCandTLR1.csv
Reconsile = sprintf('Reconsile (%s).xls', strrep(thedate,'/','-'));

[filenameR,pathR] = uiputfile(Reconsile,'Save Reconsile As');
Reconsile = sprintf('%s%s',pathR,filenameR);

fid = fopen(Reconsile, 'w');
if fid > 0
    fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Date',...
        'Card Type','Amount','Card Number','Register Number',...
        'Transaction Number','Tender Listing','Credit Card', 'Vantiv');
    for i = 1:length(finalchart)
        fprintf(fid, '%s\t%s\t%d\t%d\t%d\n', finalchart{i,1},...
            finalchart{i,2}, finalchart{i,3}, finalchart{i,4},...
            finalchart{i,5});
    end
end
clear fid i ans
end

% --- Executes on button press in ImportCCListing.
function ImportCCListing_Callback(hObject, eventdata, handles)
% hObject    handle to ImportCCListing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filenameCC,pathnameCC,ccCheck]=uigetfile('*.csv','Select the Credit Card Listing');

handles.filenameCC = filenameCC;
handles.pathnameCC = pathnameCC;
guidata(hObject, handles);

if ccCheck ~= 0
set(handles.CCDisplay, 'String', filenameCC); 
end

% --- Executes on button press in ImportVantiv.
function ImportVantiv_Callback(hObject, eventdata, handles)
% hObject    handle to ImportVantiv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filenameV,pathnameV,cCheck]=uigetfile('*.csv','Select the Vantiv Report');
handles.filenameV = filenameV;
guidata(hObject, handles);

handles.pathnameV = pathnameV;
guidata(hObject, handles);

if cCheck ~= 0
set(handles.VantivDisplay, 'String', filenameV);
end

% --- Executes on button press in ImportTenderListing.
function ImportTenderListing_Callback(hObject, eventdata, handles)
% hObject    handle to ImportTenderListing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[TLfilename,TLpathname,cCheck]=uigetfile('*.csv','Select the Tender Listing Report');

handles.TLfilename = TLfilename;
guidata(hObject, handles);

handles.TLpathname = TLpathname;
guidata(hObject, handles);

if cCheck ~= 0
set(handles.TenderListingDisplay, 'String', TLfilename); 
end


% --- Executes on selection change in TenderListingDisplay.
function TenderListingDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to TenderListingDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TenderListingDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TenderListingDisplay

% --- Executes during object creation, after setting all properties.
function TenderListingDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TenderListingDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CCDisplay.
function CCDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to CCDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CCDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CCDisplay


% --- Executes during object creation, after setting all properties.
function CCDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CCDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in VantivDisplay.
function VantivDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to VantivDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns VantivDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VantivDisplay


% --- Executes during object creation, after setting all properties.
function VantivDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VantivDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
