from lxml import etree
import re
import configparser
import os

# import local files


def printBugItem(iptItem):
    pass



def readEtreeByXpath(iptTree,xpString):
    regexpNS = "http://exslt.org/regular-expressions"
    searchHandler = etree.XPath(xpString,namespaces={"re":regexpNS})
    found = searchHandler(iptTree)
    return found

def readXpathFromConfig(configFile,configHead,configStr):
    reader = configparser.ConfigParser()
    reader.read(configFile)
    readerResult = reader[configHead][configStr]
    return readerResult

def readEtreeInfo(iptTree,xpString):
    # xpString is identifier
    xpathFromConfig = readXpathFromConfig("example.ini","xpathes",xpString)
    found = readEtreeByXpath(iptTree,xpathFromConfig)
    return found

# def local funcitons
def formatItem(d):
    try:
        rst = d.replace(".","").replace(" ","")
    except Exception as e:
        print(e)
        print(d)
        rst = str(d)
    return rst

def nameSubCC(subccName):
    return "SUB_"+subccName



def isSummary(rowItem):
    itemID = rowItem[0]
    itemVal = rowItem[2]

    # find bug item 
    if not formatItem(itemID).isdigit():
        # print(itemID)
        pass

    isSummary = 0
    if "/" in itemID:
        pass
    elif itemVal == "" or itemVal == 0:
        isSummary = 1
    elif itemID.count('.')<3:
        isSummary = 1
    else:
        pass
        
    return isSummary



def isCChead(rowEntry):
    format_val = formatItem(rowEntry[0]).lower()
    subccName = formatItem(rowEntry[1]).lower()
    #print(format_val)
    if not (format_val.isdigit() or format_val == ""):
        if "costcenter" in format_val.lower():
            if "tunnel" in subccName:
                return "tunnel"
            elif "bridge" in subccName:
                return "bridge"
            elif "road" in subccName:
                return "road"
            elif "route" in subccName:
                return "road"
            elif "interchange" in subccName:
                return "interchange"
            else:
                print(subccName)
                return "error"

    return ""

def findNameinBook(name,dictORlist,searchMethod):

    for item in dictORlist:
        if searchMethod >0:
            if name.replace(" ","").lower() in item.replace(" ","").lower():
                return name
        else:
            if item.replace(" ","").lower() in name.replace(" ","").lower():
                return item

    return ""



def calNodeSum(currCrusor):
    subNodes = currCrusor.xpath('.//LEAF')

    temptotal = 0.0
    for tempNode in subNodes:
        # temptotal = tempNode.get("THISPRD")+temptotal
        if tempNode.find("THISPRD").text == "":
            tempnum = 0.0
        else:
            tempnum = float(tempNode.find("THISPRD").text)
            # if tempnum >0 :
            #     print(tempnum)
        
        temptotal = tempnum+temptotal
    
    # currCrusor.set("SUMTOTAL",str(rowItem[0]))
    currCrusor.set("SUMTHISP",str(temptotal))
    # currCrusor.set("SUMTPREV",str(rowItem[0]))
    return

def getCCheadID(rowEntry):
    rowItem = rowEntry[0]
    # print(rowItem)
    ccIDString = ""
    validC = ['1','2','3','4','5','6','7','8','9','0','.']
    for c in rowItem:
        if c in validC:
            # print(c)
            ccIDString = ccIDString + c
    # print(ccIDString)
    return ccIDString

def bridgeLRjudge(iptStr0,iptStr1):
    iptStr0 = iptStr0.replace(" ","")
    iptStr1 = str(iptStr1).lower()
    if iptStr0 == "":
        if "bridge" in iptStr1:
            if ("left" in iptStr1):
                return 1
            elif("right" in iptStr1):
                return 2
    return -1

def categorizeSubCC(iptStr):   
    nameStr = iptStr.lower()
    TN = "tunnel"
    BG = "bridge"
    RD = "road"
    if TN in nameStr:
        return "TN"
    elif BG in nameStr:
        return "BG"
    elif RD in nameStr:
        return "RD"
    else:
        print("subcc categorize error:"&iptStr)

