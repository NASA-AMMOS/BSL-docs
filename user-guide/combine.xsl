<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:param name="builddir">.</xsl:param>

  <!-- standard copy template -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>
  <!-- Template to unescape text nodes -->
  <xsl:template match="text()">
    <xsl:value-of select="." disable-output-escaping="yes"/>
  </xsl:template>

  <xsl:template match="/db:book/db:info">
    <xsl:copy>
      <!-- existing attributes and children in their original order -->
      <xsl:apply-templates select="@* | node()"/>
      <!-- children of the other document root -->
      <xsl:copy-of select="document(concat($builddir, '/docinfo.xml'))/db:info/node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/db:book/db:appendix[@xml:id='app-manpages']">
    <xsl:copy>
      <!-- existing attributes and children in their original order -->
      <xsl:apply-templates select="@* | node()"/>
      <!-- specific pages -->
      <xsl:copy-of select="document(concat($builddir, '/bsl-mock-bpa.docbook.xml'))/db:article/db:refentry"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
