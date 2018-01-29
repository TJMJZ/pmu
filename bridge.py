from lxml import etree
import re
import os
import auxiliary
import xlsxwriter


def modifyBg(iptTree):

    global localworkbook
    global format2,format1

    localworkbook = xlsxwriter.Workbook('Expenses1111.xlsx')
    format2 = localworkbook.add_format({'bg_color':'green'})
    format1 = localworkbook.add_format({'bg_color':'yellow'})


    configFileName ="example.ini"
    configHead = "xpathes"
    bridgeStr = auxiliary.readXpathFromConfig(configFileName,configHead,"bridge")
    bridgeFound = auxiliary.readEtreeByXpath(iptTree,bridgeStr)


    for bridgeCC in bridgeFound:
        print("----------------------------------")
        print(bridgeCC.attrib["TEXT"])
        print("----------------------------------")
        currBridgeID = bridgeCC.attrib["ID"]
        
        currBridgeHasLeft = 0
        currBridgeHasRight = 0
        currBridgeDict = {}
        if "Moracica" in bridgeCC.attrib["TEXT"]:
            continue
        for bridgeChild in bridgeCC.iterchildren():
            # print(child.attrib["TEXT"])
            currBridgeName = bridgeCC.attrib["SNAME"]

            if "LRbridge" in bridgeChild.attrib:

                currBridgeLr = int(bridgeChild.attrib["LRbridge"])%2
                if currBridgeLr:
                    if currBridgeHasLeft:
                        idfer = str(bridgeCC.attrib["ID"])+"--"+"LeftPlus"+"--"
                        currBridgeName = currBridgeName+"Left2"
                    else:
                        currBridgeHasLeft = 1
                        idfer = str(bridgeCC.attrib["ID"])+"--"+"Left"+"--"
                        currBridgeName = currBridgeName+"Left"
                else:
                    if currBridgeHasRight:
                        idfer = str(bridgeCC.attrib["ID"])+"--"+"RightPlus"+"--"
                        currBridgeName = currBridgeName+"Right2"
                    else:
                        currBridgeHasRight = 1
                        idfer = str(bridgeCC.attrib["ID"])+"--"+"Right"+"--"
                        currBridgeName = currBridgeName+"Right"

                for lrBridgeChild in bridgeChild.iterchildren():
                    pierSection = loopPiers(currBridgeName,lrBridgeChild)

            else:
                idfer = str(bridgeCC.attrib["ID"])+"--"+"NOLR"+"--"
                pierSection = loopPiers(currBridgeName,bridgeChild)

    localworkbook.close()


def parseBGpiers(iptStr):
    if len(iptStr)<5:
        return [iptStr,-1,-1]

    spltStr = iptStr.replace(" ","").replace("m","").replace(")","")
    spltStrList = spltStr.split("stage")

    pierNo = spltStrList[0].replace(" ","").upper()
    pierStage = spltStrList[1].split("(")[0]

    try:
        stageHeight = float(spltStrList[1].split("(")[1])
    except Exception as e:
        raise(e)
        stageHeight = 0
    else:
        pass

    return [pierNo,pierStage,stageHeight]


def drawPiers(bridgeInfo,pierDict):
    global localworkbook,format2,format1
    worksheet = localworkbook.add_worksheet(bridgeInfo)

    column = 2
    for pierNo in pierDict:
        row = 0
        worksheet.write(row,column, pierNo, format2)
        worksheet.write(row,column+1, "span", format2)
        stageList = []
        for stage in pierDict[pierNo]:
            stageList.append(stage)
        while stageList:
            pierStage = max(stageList)
            height = pierDict[pierNo][pierStage][0]
            signed = pierDict[pierNo][pierStage][1]
            
            stageList.remove(pierStage)
            # find max in stageList
            # eliminate max
            row = row + 1
            # if pier is payed change color
            if signed == '0':
                thisFmt = format1
            else:
                thisFmt = format2


            worksheet.write(row,column, height, thisFmt)

        column = column +2



def loopPiers(bridgeInfo,bridgeSubitemCrusor):
    currPier = ""
    cummPier = 0
    pierDict = {}
    try:
        # if is pier
        if "piers" in bridgeSubitemCrusor.attrib["TEXT"].lower():
            # loop pier item
            for pierChild in bridgeSubitemCrusor.iterchildren():
                
                piers = parseBGpiers(pierChild.attrib["TEXT"])
                pierIsfull = pierChild.find("ISFULL").text


                # print(piers)
                if piers[0] in pierDict:
                    try:
                        pierDict[piers[0]][piers[1]]
                    except Exception as e:
                        pierDict[piers[0]].update({piers[1]:[piers[2],pierIsfull]})
                else:
                    pierDict[piers[0]] = {piers[1]:[piers[2],pierIsfull]}

                pierChild.set("pierNo",str(piers[0]))
                pierChild.set("pierStage",str(piers[1]))
                pierChild.set("pierStageH",str(piers[2]))


                # another relization:
                # ===============================
                if not currPier == piers[0]:

                    # print(bridgeInfo+currPier+"--"+str(cummPier))
                    cummPier = piers[2]
                    currPier = piers[0]
                else:
                    cummPier = cummPier+piers[2]

                # piers = piers.append() wont work!!!!!!
                piers.append(cummPier)
                # piers = [bridgeInfo,piers]
                # print(piers)
                # ===============================


            print(pierDict)
            drawPiers(bridgeInfo,pierDict)





            return 1
    except Exception as e:
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@")
        print(e)
        print(pierChild.attrib["ID"])
        return 1
    else:
        pass