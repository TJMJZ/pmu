from lxml import etree
import re
import os
import auxiliary

def modifyTn(iptTree):
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
    #         parsedInfo = parseTNmile(exvItem.attrib["TEXT"])
    #         exvItem.set("PORTAL",parsedInfo[0])
    #         if "ERROR" not in parsedInfo[0]:
    #             print(parsedInfo)
    for innSummary in innFound:
        for innItem in innSummary.iterchildren():
            parsedInfo = parseTNmile(innItem.attrib["TEXT"])
            innItem.set("PORTAL",parsedInfo[0])
            if "ERROR" not in parsedInfo[0]:
                print(parsedInfo)
                innItem.set("PORT",str(parsedInfo[0]))
                innItem.set("MILE1",str(parsedInfo[1]))
                innItem.set("MILE2",str(parsedInfo[2]))
                innItem.set("LENG",str(parsedInfo[3]))


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
