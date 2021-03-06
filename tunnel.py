from lxml import etree
import re
import os
import auxiliary
import xlsxwriter
def modifyTn(iptTree):

    localworkbook = xlsxwriter.Workbook('Expenses2222.xlsx')
    format2 = localworkbook.add_format({'bg_color':'green'})
    format1 = localworkbook.add_format({'bg_color':'yellow'})


    configFileName ="example.ini"
    configHead = "xpathes"
    # tunnel logic
    excavationStr = auxiliary.readXpathFromConfig(configFileName,configHead,"tunnelExcavation")
    innerLiningStr = auxiliary.readXpathFromConfig(configFileName,configHead,"tunnelInnerLining")

    exvFound = auxiliary.readEtreeByXpath(iptTree,excavationStr)
    innFound = auxiliary.readEtreeByXpath(iptTree,excavationStr)
    # print(exvFound)
    # for exvSummary in exvFound:
    #     for exvItem in exvSummary.iterchildren():
    #         parsedInfo = parseTNmile(exvItem.text)
    #         exvItem.set("PORTAL",parsedInfo[0])
    #         if "ERROR" not in parsedInfo[0]:
    #             print(parsedInfo)
    tunnelID = 1
    portColumn = {"SL":2,"SR":4,"NL":6,"NR":8}

    for innSummary in innFound:
        rowByPort = {"SL":1,"SR":1,"NL":1,"NR":1}





        worksheet = localworkbook.add_worksheet(str(tunnelID))
        tunnelID = tunnelID+1
        worksheet.write(0,portColumn["SL"],"SL",format1)
        worksheet.write(0,portColumn["SR"],"SR",format1)
        worksheet.write(0,portColumn["NL"],"NL",format1)
        worksheet.write(0,portColumn["NR"],"NR",format1)

        for innItem in innSummary.iterchildren():
            parsedInfo = parseTNmile(innItem.text)

            if "ERROR" not in parsedInfo[0]:
                print(parsedInfo)
                thisPort = parsedInfo[0]
                thisFmt = format2
                thisLen = innItem.attrib["LENGTH"]
                innItem.set("PORT",str(thisPort))
                innItem.set("MILE1",str(parsedInfo[1]))
                innItem.set("MILE2",str(parsedInfo[2]))
                innItem.set("LENG",thisLen)

                worksheet.write(rowByPort[thisPort],portColumn[thisPort],thisLen, thisFmt)
                rowByPort[thisPort] = rowByPort[thisPort]+1

    localworkbook.close()


def splitTnStr(spltStr,iptLR):

    if iptLR>0:
        LRstr = "RK"
    elif iptLR<0:
        LRstr = "LK"
    else:
        pass
    splitStrList = spltStr.split(LRstr)
    if len(splitStrList)<3:
        print("-------------split string error: "+spltStr)
        splitStrList = spltStr.split("K")

    pile1str = splitStrList[1].replace("L","").replace("R","")
    pile2str = splitStrList[2].replace("L","").replace("R","").replace(")","")

    try:
        pile1 = float(pile1str)
        pile2 = float(pile2str)
    except Exception as e:
        print(splitStrList)
        pile1str = pile1str.replace(",",".")
        pile2str = pile2str.replace(",",".")
        try:
            pile1 = float(pile1str)
            pile2 = float(pile2str)
        except Exception as e:
            pile1str = pile1str.replace(".","",1)
            pile2str = pile2str.replace(".","",1)
            pile1 = float(pile1str)
            pile2 = float(pile2str)


    return [pile1,pile2]


def parseTNmile(iptStr):

	# if item is like "20m" and no more info
	# 
    if len(iptStr)<10:

        return ["NOTYET ERROR",0,0,0]

    iptStr = iptStr.replace("-","").replace("+","").replace(" ","").replace("—","").replace("~","")

    # regular expression
    #tnPattern = "\d*[mM](.*)[nNsS]-*[lLrR](.*)"
    #tnPatternRe = re.compile(tnPattern)

    if "SR" in iptStr:
        portal = "SR"
        pile = splitTnStr(iptStr,1)

    elif "NR" in iptStr:
        portal = "NR"
        pile = splitTnStr(iptStr,1)

    elif "SL" in iptStr:
        portal = "SL"
        pile = splitTnStr(iptStr,-1)

    elif "NL" in iptStr:
        portal = "NL"
        pile = splitTnStr(iptStr,-1)

    else:
        return ["ERROR",0,0,0]

    pile0 = pile[0]
    pile1 = pile[1]

    return [portal,pile0,pile1,abs(pile0-pile1)]

    # if len(test) > 10:
    #     print(test)
