<?xml version="1.0" encoding="UTF-8"?>
<!--
example ways to process this xslt:
$ java -cp xalan-2.6.0.jar \
  org.apache.xalan.xslt.Process -xml -in log4sh.xml -xsl shelldoc.xslt

$ xsltproc shelldoc.xslt log4sh.xml |xmllint -noblanks -
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:s="http://www.forestent.com/2005/XSL/ShellDoc">
  <xsl:output
      method="xml"
      version="1.0"
      encoding="UTF-8"
      indent="yes"/>
  <xsl:strip-space elements="*" />

  <xsl:variable name="newline">
<xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:key name="groups" match="s:function" use="@group" />

  <xsl:template match="/">
    <article id="shelldoc" lang="en-US">
    <xsl:for-each select="//s:function[generate-id(.)=generate-id(key('groups', @group)[1])]">
      <xsl:sort select="@group" />

      <table><title><xsl:value-of select="@group" /></title>
        <tgroup cols="2"><tbody>
        <xsl:for-each select="key('groups', @group)">
          <xsl:sort select="entry/funcsynopsis/funcprototype/funcdef/function" />
          <row valign="top">
	    <xsl:copy-of select="entry" />
	    <!--<xsl:apply-templates select="entry" />-->
	  </row>
        </xsl:for-each>
        </tbody></tgroup>
      </table>
    </xsl:for-each>
    </article>
  </xsl:template>

  <xsl:template match="entry">
    <entry>
    <xsl:copy-of select="*" />
    </entry>
  </xsl:template>

</xsl:stylesheet>
