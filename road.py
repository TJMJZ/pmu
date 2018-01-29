from lxml import etree
import re
import os
import auxiliary

def modifyRd(iptTree):

    configFileName ="example.ini"
    configHead = "xpathes"
    roadStr = auxiliary.readXpathFromConfig(configFileName,configHead,"road")
    roadStr = roadStr+"//NODE[re:test(@TEXT,'.*subgrade.*','i')]"
    roadFound = auxiliary.readEtreeByXpath(iptTree,roadStr)

    roadDict = {}
    for roadCC in roadFound:
        # print("----------------------------------")
        # print(roadCC.attrib["TEXT"])
        # print("----------------------------------")
        
        # print(parseRDmile(roadCC.attrib["TEXT"]))


        for roadChild in roadCC.iterchildren():
            childKey = roadChild.attrib["TEXT"].split('/')[0]
            if childKey in roadDict:
                roadDict[childKey] = roadDict[childKey]+1
            else:
                roadDict[childKey] = 1

    
    print(roadDict)
            # print(childKey)

            # for child in roadChild:
            #     try:
            #         print(child.attrib["TEXT"])
            #     except Exception as e:
            #         print(e)
            #     finally:
            #         pass




def parseRDmile(iptStr):

    spltStr = iptStr.replace("-","").replace("+","").replace(" ","").replace("—","").replace("~","").replace(",","")
    print(iptStr)

    lkStr = "LK"
    rkStr = "RK"

    if (lkStr in spltStr) and (rkStr in spltStr):
        splitLkList = spltStr.split(lkStr)
        splitRkList = splitLkList[2].split(rkStr)
        try:
            lk1 = float(splitLkList[1])
            lk2 = float(splitRkList[0])
            rk1 = float(splitRkList[1])
            rk2 = float(splitRkList[2].replace(")",""))
        except Exception as e:
            print(spltStr)
            lk1 = -1
            lk2 = -1
            rk1 = -1
            rk2 = -1
    elif (lkStr in spltStr) and (rkStr not in spltStr):
        splitLkList = spltStr.split(lkStr)
        lk1 = float(splitLkList[1])
        lk2 = float(splitLkList[2].replace(")",""))
        rk1 = -1
        rk2 = -1
    elif (lkStr not in spltStr) and (rkStr in spltStr):
        splitRkList = spltStr.split(rkStr)
        rk1 = float(splitRkList[1])
        rk2 = float(splitRkList[2].replace(")",""))
        lk1 = -1
        lk2 = -1
    else:
        lk1 = -1
        lk2 = -1
        rk1 = -1
        rk2 = -1
    return [[lk1,lk2],[rk1,rk2]]



