<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <!--  
        This stylesheet merges the metadata from the Corpus document and the 
        TEI-represenation of the ELAN transcriptions. 
        
        TODOs mentioned inline.
        
        Author: Daniel Schopper
        Created: 2022-03-12
    -->
    
    <xsl:param name="pathToCorpusDoc"/>
    <xsl:variable name="input" select="."/>
    <xsl:variable name="corpusDoc" select="doc($pathToCorpusDoc)" as="document-node()"/>
    <xsl:variable name="IDcandidates" select="$corpusDoc/tei:teiCorpus/tei:TEI//tei:title[@level = 'a']"/>
    <xsl:variable name="pathSegs" select="tokenize(base-uri($input),'/')"/>
    <xsl:variable name="recordingIDfromFilename" select="substring-before(substring-after($pathSegs[starts-with(.,'ELAN_')],'ELAN_'),'.xml')"/>
    <xsl:variable name="recordingID" select="$IDcandidates[. = $recordingIDfromFilename]"/>
    <xsl:variable name="teiHeaderFromCorpus" select="$recordingID/ancestor::tei:teiHeader" as="element(tei:teiHeader)?"/>
    
    <xsl:template match="/">
        <xsl:if test="count($recordingID) gt 1">
            <xsl:message>WARNING found several matching recording IDs: <xsl:value-of select="string-join($recordingID, ', ')"/> - taking first one</xsl:message>
        </xsl:if>
        <xsl:if test="normalize-space($recordingID) = ''">
            <!--<xsl:message select="concat('$input=',base-uri($input))"/>
            <xsl:message select="concat('$pathToCorpusDoc=',$pathToCorpusDoc)"/>
            <xsl:message select="concat('$IDcandidates=',string-join($IDcandidates,', '))"/>
            <xsl:message select="concat('$recordingID=',$recordingID)"/>-->
            <xsl:message>$recordingID could not be determined from input filename <xsl:value-of select="tokenize(base-uri($input),'/')[last()]"/></xsl:message>
        </xsl:if>
        <xsl:if test="not($teiHeaderFromCorpus)">
            <!--<xsl:message select="concat('$input=',base-uri($input))"/>
            <xsl:message select="concat('$pathToCorpusDoc=',$pathToCorpusDoc)"/>
            <xsl:message select="concat('$IDcandidates=',string-join($IDcandidates,', '))"/>
            <xsl:message select="concat('$recordingID=',$recordingID)"/>-->
            <xsl:message>teiHeader for recording <xsl:value-of select="$recordingID"/> not found in <xsl:value-of select="$pathToCorpusDoc"/></xsl:message>
        </xsl:if>
        <xsl:comment>THIS FILE WAS PROGRAMMATICALLY CREATED by mergeHeaderAndTranscription.xsl on/at<xsl:value-of select="current-dateTime()"/></xsl:comment>
        <xsl:apply-templates>
            <xsl:with-param name="teiHeaderFromCorpus" select="$teiHeaderFromCorpus" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="tei:TEI">
        <xsl:copy>
            <xsl:sequence select="$teiHeaderFromCorpus/../@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- TODO: make a real merge, i.e. include relelvant metadata from the ELAN export 
        and not just overwrite it with the corpus header -->
    <xsl:template match="tei:teiHeader">
        <xsl:param name="teiHeaderFromCorpus" tunnel="yes"/>
        <xsl:sequence select="$teiHeaderFromCorpus"/>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:annotationBlock">
        <annotationBlock>
            <xsl:apply-templates select="node()"/>
        </annotationBlock>
    </xsl:template>
    
    <xsl:template match="tei:u">
        <u xml:lang="ar-acm-x-shawi-vicav" xml:id="{concat($recordingID,'_',../@xml:id)}" who="{concat('#', ../@who)}">
          <xsl:apply-templates select="../@* except (../@xml:id, ../@who)"/>
          <xsl:apply-templates select="tei:seg"/>
        </u>
    </xsl:template>
    
    <xsl:template match="tei:seg">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="tei:span">
        <span xml:lang="en" target="{concat('#', $recordingID,'_',substring(@target, 2))}">
            <xsl:apply-templates select="@* except @target|node()"/>
        </span>
    </xsl:template>
    
</xsl:stylesheet>