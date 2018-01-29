# import system files
import xlrd
from lxml import etree
import auxiliary
import re
import os
import configparser
import tunnel
import bridge
import road

summaryDict = {"tunnel":["excavation","secondary","portal","finish","pavement","facilities","equipment","engineering"],
                "bridge":["foundation","piers","superstructure","deck","span","prestress","furniture","asphalt","engineering"]}
tunnelNameDict = {"suka":1,"vezesnik":2,"mrke":4,
    "klopot":5,"vilac":6,"vjeternik":7,
    "mrkikrs":8,"durilovac":9,"kosman":10,"malatrava":11,
    "vitanovice":13,"zecka":15,"pajkovvir":16,
    "jabuckikrs":17,"preslo":18}

bridgeNameDict = {"gornjemrke":1,"moracica":2,"djuricevlaz":3,"ratkovlaz":4,"lutovo":5,"suvovara":6,"krkor":7,"mistica":8,
    "zagrade":9,"podovi":10,"estogaz":28,"uvac1":11,"uvac2":12,"uvac3":13,"uvac4":14,"pajkovvir":15,"preslo":16,"jabuka":17,"tara1":18,"tara2":19}
ccDict = {"tunnel":tunnelNameDict,"bridge":bridgeNameDict}



wb = xlrd.open_workbook("revised2.xlsx")

# create tree
IPC015ROOT = etree.Element('IPC015')
IPC015ROOT.set('DATE', '20171231')
IPC015ROOT.set('LEVEL', str(0))
IPC015TREE = etree.ElementTree(IPC015ROOT)

# print corner cases 
print("-------------printing corner cases-------------")
for sheetNumber in range(1,15):
    if sheetNumber < 10:
        sh = wb.sheet_by_name("COST CENTER "+"0"+str(sheetNumber))
    else:
        sh = wb.sheet_by_name("COST CENTER "+str(sheetNumber))
    for row in range(10, sh.nrows):
        val = sh.row_values(row)[0]
        format_val = val.replace(".","").replace(" ","")
        if not (format_val.isdigit() or format_val == ""):
            if not "costcenter" in format_val.lower():
                print(val)
print("----------------finish printing----------------")


# read xlsx
for sheetNumber in range(1,15):
    print(sheetNumber)
    tempCC = etree.SubElement(IPC015ROOT,"CostCenter")
    tempCC.set("ID",str(sheetNumber))
    tempCC.set("LEVEL",str(1))

    if sheetNumber < 10:
        sh = wb.sheet_by_name("COST CENTER "+"0"+str(sheetNumber))
    else:
        sh = wb.sheet_by_name("COST CENTER "+str(sheetNumber))

    for row in range(9, sh.nrows):
        rowItem = sh.row_values(row)

        #print(rowItem[0])
        # print(auxiliary.isCChead(rowItem))
        if auxiliary.isCChead(rowItem):
            subccName = auxiliary.isCChead(rowItem)

            nameSubCCList = {"tunnel":auxiliary.nameSubCC,
                             "bridge":auxiliary.nameSubCC,
                             "road":auxiliary.nameSubCC,
                             "interchange":auxiliary.nameSubCC,
                             "error":print}


            namesubccFun = nameSubCCList[subccName]
            sccnameStr = namesubccFun(subccName)

            ccID = auxiliary.getCCheadID(rowItem)
            subCC = etree.SubElement(tempCC,sccnameStr)
            # subCC.text = rowItem[1]
            subCC.set("LEVEL",str(2))
            subCC.set("ID",ccID)
            subCC.set("DSTR",rowItem[1])
            if subccName in ccDict:
                structureName = auxiliary.findNameinBook(rowItem[1],ccDict[subccName],-1)
                if structureName:
                    subCC.set("SNAME",structureName)
            else:
                subCC.set("SNAME","NO")

            currCrusor = subCC
            if "bridge" in rowItem[1].lower():
                resetLbridge = 0
                resetRbridge = 0

        elif auxiliary.bridgeLRjudge(rowItem[0],rowItem[1])>0:
            if auxiliary.bridgeLRjudge(rowItem[0],rowItem[1]) == 1:
                lrName = "SUB_BLEFT"
            else:
                lrName = "SUB_BRIGHT"

            lrBridge = etree.SubElement(subCC,lrName)
            lrBridge.set("ID",subCC.get("ID"))
            lrBridge.set("LEVEL",str(2))
            lrBridge.set("DSTR",str(rowItem[1].split("/")[0]))
            lrBridge.set("LRbridge",str(auxiliary.bridgeLRjudge(rowItem[0],rowItem[1])))
            currCrusor = lrBridge

        else:
            # judge this item
            while True:

                # if no ID then break to next item
                if rowItem[0] == "":
                    break

                # currCrusor is the parent of currRowItem
                elif (currCrusor.get("ID") in rowItem[0]):

                    # currRow is a summary
                    if auxiliary.isSummary(rowItem):
                        temp = "NODE"
                        thisSummaryName = rowItem[1]
                        try:
                            foundInDict = ""
                            if "tunnel" in currCrusor.get("DSTR").lower():
                                foundInDict = auxiliary.findNameinBook(thisSummaryName,summaryDict["tunnel"],-1)

                                # for thisItem in summaryDict["tunnel"]:
                                #     if thisItem in thisSummaryName.lower():
                                #         temp = thisItem
                                #         foundInDict = True
                                #         break
                            elif "bridge" in currCrusor.get("DSTR").lower():
                                foundInDict = auxiliary.findNameinBook(thisSummaryName,summaryDict["bridge"],-1)
                                # for thisItem in summaryDict["bridge"]:
                                #     if thisItem in thisSummaryName.lower():
                                #         temp = thisItem
                                #         foundInDict = True
                                #         break
                            else:
                                foundInDict = "NODE"

                            if not foundInDict:
                                print(rowItem[0]+"----"+thisSummaryName)
                                foundInDict = "NODE"

                        except Exception as e:
                            print(e)
                            print(rowItem[0])
                            foundInDict = "NODE"

                        newentry = etree.SubElement(currCrusor,foundInDict)
                        newentry.set("ID",str(rowItem[0]))
                        
                        newentry.set("DSTR",str(rowItem[1].split("/")[0]))
                        
                        currCrusor = newentry
                    # is leaf
                    # leaf has no children
                    else:
                    	
                        newentry = etree.SubElement(currCrusor,"LEAF")
                        try:
                            tempString = currCrusor.get("DSTR").lower()
                        except Exception as e:
                            tempString = ""

                    
                        if "preliminary" in tempString:
                            rowItemlast = sh.row_values(row-1)
                            
                            try:
                                thismile = float(rowItem[1].split("m",1)[0])
                            except Exception as e:
                                thismile = 0
                                print(e)


                            try:
                                lastmile = float(rowItemlast[1].split("m",1)[0])
                            except Exception as e:
                                lastmile = 0
                                print(e)
                            else:
                                pass

                            thislength = thismile-lastmile
                            newentry.set("LENGTH",str(thislength))



                        
                        newentry.set("ID",str(rowItem[0]))
                        newentry.text = str(rowItem[1])
                        newentry.set("TOTALAMT",str(rowItem[2]).split(".")[0])
                        newentry.set("THISPRD",str(rowItem[6]).split(".")[0])
                        newentry.set("PREVCM",str(rowItem[5]).split(".")[0])

                        # etree.SubElement(newentry,"TOTALAMT").text = str(rowItem[2])
                        # etree.SubElement(newentry,"THISPRD").text = str(rowItem[6])
                        # etree.SubElement(newentry,"PREVCM").text = str(rowItem[5])

                        if rowItem[6] == rowItem[2]:
                            newentry.set("ISFULL","1")
                        elif rowItem[5]+rowItem[6] == rowItem[2]:
                            newentry.set("ISFULL","2")
                        else:
                            newentry.set("ISFULL","-1")
                        
                    

                    break
                    # print(currCrusor)

                else:
                    currCrusor = currCrusor.getparent()





# modify tree




# for element in IPC015TREE.xpath('//IPC015'):
#     auxiliary.calNodeSum(element)

# for element in IPC015TREE.xpath('//CostCenter'):
#     auxiliary.calNodeSum(element)

# for element in IPC015TREE.xpath('//SubCostCenter'):
#     auxiliary.calNodeSum(element)

# for element in IPC015TREE.xpath('//NODE'):
#     auxiliary.calNodeSum(element)


try:
    tunnel.modifyTn(IPC015TREE)
except Exception as e:
    raise(e)
else:
    pass

    
# tunnel.modifyTn(IPC015TREE)
bridge.modifyBg(IPC015TREE)
# road.modifyRd(IPC015TREE)



IPC015TREE.write('test11.xml', pretty_print=True, xml_declaration=True, encoding='utf-8')
