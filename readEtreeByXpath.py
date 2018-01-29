from lxml import etree
import re
import configparser

def readEtreeByXpath(iptTree,xpString):
	regexpNS = "http://exslt.org/regular-expressions"
	find = etree.XPath(xpString,namespaces={"re":regexpNS})
	found = find(iptTree)
	return found

def readEtreeInfo(iptTree,xpString):
	# xpString is identifier
	configthis = configparser.ConfigParser()
	configthis.read('example.ini')
	configread = configthis['xpathes'][xpString]
	found = readEtreeByXpath(configread)
	return found