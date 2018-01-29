from lxml import etree

IPC015ROOT = etree.Element('IPC015')
IPC015ROOT.set('DATE', '20171231')
IPC015ROOT.set('LEVEL', '1')

IPC015TREE = etree.ElementTree(IPC015ROOT)

CC01 = etree.SubElement(IPC015ROOT,"CC01")
CC01.set("id",'1')
CC01.set("issubroot",'1')

temp = etree.Element("subcostcenter")
temp.text = "costcenter1.1"
temp.set("LEVEL",'3')
temp.set("CONTENT","roads and walls")


CC01.append(temp)

# name = etree.Element('nodes')
# IPC015ROOT.append(name)


IPC015TREE.write('111.xml', pretty_print=True, xml_declaration=True, encoding='utf-8')
    #element = etree.SubElement(name, 'node')
    #element.set('id', str(val[0]))
    #element.set('x', str(val[1]))
    #element.set('y', str(val[2]))
#IPC015TREE.write('test.xml', pretty_print=True, xml_declaration=True, encoding='utf-8')
