<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks"
                 exclude-result-prefixes="#all"
                 version="2.0"
                 xml:base="postTokenization.xsl">
   <xsl:output method="xml" indent="no"/>
   <xsl:strip-space elements="*"/>
   <xsl:param name="debug"/>
   <xsl:template match="/">
      <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="../082_scripts_xsl/tei_2_html__simple_text.xsl"</xsl:processing-instruction>
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="xslt">inPathSegment="\010_manannot\" outPathSegment="\106_html\"</xsl:processing-instruction>
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="processor">name="saxon" removePreserveFromXML="true" removePreserveFromXSLT="true"</xsl:processing-instruction>
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="snippets">fn="snippets_shawi_001.xml" path="{filePath}/../880_conf/"</xsl:processing-instruction>
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="standoff">fn="shawi_standoff.xml" path=""</xsl:processing-instruction>
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="attributeAssignments">fn="shawi_attributes.xml" path="{filePath}/../880_conf/"</xsl:processing-instruction>
      <xsl:text>
</xsl:text>
      <xsl:processing-instruction name="shortCuts">fn="shawi_shortCuts" path="{filePath}/../880_conf/"</xsl:processing-instruction>
      <xsl:text>
</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="node() | @*">
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="tei:seg[xtoks:w|xtoks:pc]">
      <xsl:call-template name="groupTokenParts"/>
   </xsl:template>
   <xsl:template match="*[not(self::tei:seg)][xtoks:w]">
      <xsl:copy>
         <xsl:apply-templates select="@*"/>
         <xsl:call-template name="groupTokenParts"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template name="groupTokenParts">
      <xsl:for-each-group group-starting-with="xtoks:ws" select="node()">
         <xsl:variable name="first-is-ws" select="exists(current-group()[1]/self::xtoks:ws)"/>
         <xsl:variable name="last-is-pc"
                        select="exists(current-group()[last()]/self::xtoks:pc)"/>
         <xsl:choose>
                <!-- first token = ws, last token = pc > fetch all in between into group -->
            <xsl:when test="$first-is-ws and $last-is-pc">
               <xsl:choose>
                        <!-- let's count how many parts except the first and the last are left -->
                        <!-- if there are more then 1, then wrap them ... -->
                  <xsl:when test="count(current-group())-2 gt 1">
                     <xsl:variable name="parts-in-between"
                                    select="current-group()[position() gt 1][not(. is current-group()[last()])]"/>
                     <xsl:apply-templates select="current-group()[1]"/>
                     <seg xmlns="http://www.tei-c.org/ns/1.0" type="connected">
                        <xsl:for-each select="$parts-in-between">
                           <xsl:apply-templates select=".">
                              <xsl:with-param tunnel="yes"
                                               name="join"
                                               select="if (exists(following-sibling::*) and not(following-sibling::*[1]/self::xtoks:ws)) then 'right' else ''"/>
                           </xsl:apply-templates>
                        </xsl:for-each>
                     </seg>
                     <xsl:apply-templates select="current-group()[last()]"/>
                  </xsl:when>
                  <!-- .. otherwise, don't wrap them -->
                  <xsl:otherwise>
                     <xsl:apply-templates select="current-group()"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <!-- first token != ws, last token = pc  -->
            <xsl:when test="not($first-is-ws) and $last-is-pc">
               <xsl:choose>
                  <xsl:when test="count(current-group() except current-group()[last()]) gt 1">
                     <seg xmlns="http://www.tei-c.org/ns/1.0" type="connected">
                        <xsl:for-each select="current-group()[position() lt count(current-group())]">
                           <xsl:apply-templates select=".">
                              <xsl:with-param tunnel="yes"
                                               name="join"
                                               select="if (exists(following-sibling::*) and not(following-sibling::*[1]/self::xtoks:ws)) then 'right' else ''"/>
                           </xsl:apply-templates>
                        </xsl:for-each>
                     </seg>
                     <xsl:apply-templates select="current-group()[last()]"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:apply-templates select="current-group()"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <!-- first token = ws, last token != pc -->
            <xsl:when test="$first-is-ws and not($last-is-pc)">
               <xsl:choose>
                  <xsl:when test="count(current-group()[position() gt 1]) gt 1">
                     <xsl:apply-templates select="current-group()[1]"/>
                     <seg xmlns="http://www.tei-c.org/ns/1.0" type="connected">
                        <xsl:for-each select="current-group()[position() gt 1]">
                           <xsl:apply-templates select=".">
                              <xsl:with-param tunnel="yes"
                                               name="join"
                                               select="if (exists(following-sibling::*) and not(following-sibling::*[1]/self::xtoks:ws)) then 'right' else ''"/>
                           </xsl:apply-templates>
                        </xsl:for-each>
                     </seg>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:apply-templates select="current-group()"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="count(current-group()) gt 1">
                     <seg xmlns="http://www.tei-c.org/ns/1.0" type="connected">
                        <xsl:for-each select="current-group()">
                           <xsl:apply-templates select=".">
                              <xsl:with-param tunnel="yes" name="join">
                                 <xsl:if test="exists(following-sibling::*[not(self::xtoks:ws)]) and not(following-sibling::*[1]/self::xtoks:ws)">right</xsl:if>
                              </xsl:with-param>
                           </xsl:apply-templates>
                        </xsl:for-each>
                     </seg>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:apply-templates select="current-group()"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each-group>
   </xsl:template>
   <xsl:template match="xtoks:w[exists(following-sibling::*) and not(following-sibling::*[1]/self::xtoks:ws)]">
      <xsl:copy copy-namespaces="no">
         <xsl:copy-of select="@* except @xml:id"/>
         <xsl:attribute name="xtoks:id"
                         select="concat(root()//tei:title[@level ='a'],'_',@xtoks:id)"/>
         <xsl:attribute name="join">right</xsl:attribute>
         <xsl:if test="following-sibling::*[1]/self::xtoks:pc[. = '-']">
            <xsl:attribute name="rend">withDash</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="xtoks:w">
      <xsl:param tunnel="yes" name="join"/>
      <xsl:copy copy-namespaces="no">
         <xsl:copy-of select="@* except @xtoks:id"/>
         <xsl:if test="$join != ''">
            <xsl:attribute name="join" select="$join"/>
         </xsl:if>
         <xsl:attribute name="xtoks:id"
                         select="concat(root()//tei:title[@level ='a'],'_',@xtoks:id)"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="xtoks:pc[.='-']"/>
   <xsl:template match="tei:u/tei:seg">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:when[@xml:id = 'T0']/@absolute"/>
</xsl:stylesheet>
