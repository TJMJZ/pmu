<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Edited with XML Spy v2007 (http://www.altova.com) -->
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method='html' version='1.0' encoding='UTF-8' indent='yes'/>

<xsl:template match="/">
  <html>
  <body>
  <h2>My CD Collection</h2>
    <table border="1">
      <tr bgcolor="#9acd32">
        <th align="left">BRIDGE</th>
        <th align="left">LR</th>
        <th align="left">FOUNDATION</th>
        <th align="left">PIER</th>
        <th align="left">THISAMT</th>
      </tr>
      <xsl:for-each select="//SUB_bridge/SUB_BLEFT//LEAF">
      <tr>
        <td><xsl:value-of select="../../../@SNAME"/></td>
        <td><xsl:value-of select="name(..)"/></td>
        <td><xsl:value-of select="./TOTALAMT"/></td>
        <td><xsl:value-of select="./@ID"/></td>
        <td><xsl:value-of select="./@TEXT"/></td>
      </tr>
      </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>
</xsl:stylesheet>