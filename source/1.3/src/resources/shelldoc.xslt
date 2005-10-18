<?xml version="1.0" encoding="UTF-8"?>
<!--
example usage:
$ java -cp xalan-2.6.0.jar org.apache.xalan.xslt.Process \
-xml -in mktg_emails.xml -xsl emails_by_client_id.xslt
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.4//EN" "http://www.oasis-open.org/docbook/xml/4.4/docbookx.dtd">
    <article id="shelldoc" lang="en-US">
      <xsl:apply-templates select="shelldoc"/>
    </article>
  </xsl:template>

  <xsl:template match="shelldoc">
    <xsl:apply-templates select="s:function"/>
  </xsl:template>

  <xsl:template
</xsl:stylesheet>
