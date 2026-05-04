<!-- These parameters tweak the XHTML settings.
Options are listed in https://docbook.sourceforge.net/release/xsl/current/doc/html/
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
  xmlns:m="http://docbook.org/ns/docbook/modes"
  exclude-result-prefixes="db l m" version="3.0">
  <!-- use catalog resolver for this URL -->
  <xsl:import href="http://docbook.org/ns/docbook/docbook.xsl"/>

  <xsl:param name="user-css-links">css/manual.css</xsl:param>
  <xsl:param name="use-docbook-css" select="true()" />

  <xsl:param name="revhistory-style">list</xsl:param>
  <xsl:param name="sections-inherit-from">component section</xsl:param>
  <xsl:param name="section-toc-depth">2</xsl:param>
  <xsl:param name="persistent-toc" select="true()"/>

  <xsl:param name="qandaset-default-toc" select="false()"/>
  <xsl:param name="qandaset-default-label">none</xsl:param>
</xsl:stylesheet>
