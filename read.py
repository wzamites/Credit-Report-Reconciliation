from decimal import *

#---- Import the files
F = open("/Users/bj_zamites/Desktop/Reconcile/062317/062317.csv", "r")
TL = F.read().split('\r')
F.close()

F = open("/Users/bj_zamites/Desktop/Reconcile/062317/cc06232017.csv", "r")
CC = F.read().split('\r')
F.close()

F = open("/Users/bj_zamites/Desktop/Reconcile/062317/VT062317.csv", "r")
VT = F.read().split('\r')
F.close()

#----- CC report to 6 columns

CCreport =[]

#Find what line the thing starts on
for start in range(13):
    if CC[1][start:start+2] == '  ':
        break;

#for every line in the text file...
for ii in range(2,len(CC)-1):
    #get the card type at the top. Other ifs will fail until the next ii
    if CC[ii][start] <> ' ':
        cardtype = CC[ii][start:100].strip().upper()

    #This identifies lines with the data on it.
    #If true, it will always come after the card type line
    if CC[ii][start+75] == '0':
        thedate = CC[ii][start+55:start+67].strip() 
        theprice = CC[ii][start+42:start+55].strip().replace(",", "")
        accountnum = CC[ii][start+5:start+21].upper()
        registernum = CC[ii][start+78]
        transnum = CC[ii][start+84:start+88]

        newline = [thedate, cardtype, theprice, accountnum, registernum, transnum]
        CCreport.append(newline)
        
#------ TLR to 5 columns + 1 array of transaction numbers
        #This is gonna remove the duplicates too
        
TLreport = []

count = -1

for start in range(10):
    if ''.join(list(TL[1])[start:start+2]) == '  ':
        break

for i in range(2,len(TL)-1):
    if TL[i][start] != ' ':
        cardtype = TL[i][start:100].strip()
    if not (cardtype == 'VISA' or cardtype == 'MASTERCARD' or cardtype == 'AMEX' or cardtype == 'DISCOVER'):
        continue
    
    if TL[i][start+79] == '0':
        count = count + 1;
        
        amount = TL[i][start:start+17].strip().replace(',', '')
        acctnumber = TL[i][start+24:start+45].strip().upper()
        regnum = TL[i][start+82]
        transnum = TL[i][start+94:start+98]

        newline = [thedate, cardtype, amount, acctnumber, regnum, transnum]
        TLreport.append(newline)

#Removes Duplicates
for line in TLreport:
    if TLreport.count(line) > 1:
        for i in range(TLreport.count(line)-1):
            TLreport.remove(line)

#Combine CC and TR

#------ VT to 5 columns + 1

    #split the file into a list of lists
count = -1
for x in VT:
    count = count + 1
    VT[count] = x.split(',')

    #find the indexes of all the shits u need
cardtypeind = VT[0].index('CardLogo')
approvedamountind = VT[0].index('ApprovedAmount')
transamountind = VT[0].index('TransactionAmount')
acctnumberind = VT[0].index('CardNumberMasked')
regnumind = VT[0].index('LaneNumber')

    #make the list
VTreport = []
for i in range(1,len(VT)-1):
    cardtype = VT[i][cardtypeind].upper()
    approvedamount = VT[i][approvedamountind]
    transamount = VT[i][transamountind]
    acctnumber = VT[i][acctnumberind].replace('-','').upper()
    regnum = VT[i][regnumind]

    if approvedamount == '':
        newline = (thedate, cardtype, '%.2f' % (float(transamount) * -1)
                   , acctnumber, regnum)
    else:
        newline = (thedate, cardtype, '%.2f' % float(approvedamount)
                   , acctnumber, regnum)

    VTreport.append(newline)

#----- Combine CC and TR if they're unique
CCandTL = []
CCandTL = CCandTL + TLreport

for line in CCreport:
    if not (line in TLreport):
        CCandTL.append(line)

#get the transaction numbers into a separate thing
TransactionNumbers = []
for line in CCandTL:
    TransactionNumbers.append(line[5])
    del line[5]
