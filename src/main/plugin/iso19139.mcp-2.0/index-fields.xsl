<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0" xmlns:gmd="http://www.isotc211.org/2005/gmd"
			xmlns:gmx="http://www.isotc211.org/2005/gmx"
			xmlns:gco="http://www.isotc211.org/2005/gco"
			xmlns:gml="http://www.opengis.net/gml"
			xmlns:srv="http://www.isotc211.org/2005/srv"
			xmlns:geonet="http://www.fao.org/geonetwork"
			xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
			xmlns:xlink="http://www.w3.org/1999/xlink"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="gmd gmx gco gml srv geonet mcp xlink xsl">


	<xsl:import href="../iso19139/index-fields/default.xsl"/>
	<xsl:include href="../iso19139/convert/functions.xsl"/>

	<xsl:template mode="index" match="/*">
		<!-- Index distinct platforms for facetted searching -->

		<xsl:for-each-group select="//mcp:platform" group-by="mcp:DP_Term/mcp:term/gco:CharacterString">
			<Field name="platform" string="{current-grouping-key()}" store="true" index="true"/>
			<Field name="platformUri" string="{current-group()[1]//mcp:vocabularyTermURL/gmd:URL[1]}" store="true" index="true"/>
		</xsl:for-each-group>

		<!-- Index distinct responsible party and point of contact -->
		<!-- organisations for facetted searching                  -->

		<xsl:variable name="pointOfContactOrganisations" select="gmd:identificationInfo/(gmd:MD_DataIdentification|mcp:MD_DataIdentification)/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName/*"/>
		<xsl:variable name="responsiblePartyOrganisations" select="gmd:identificationInfo/(gmd:MD_DataIdentification|mcp:MD_DataIdentification)/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/*"/>

		<xsl:for-each-group select="$pointOfContactOrganisations|$responsiblePartyOrganisations" group-by=".">
			<Field name="organisation" string="{string(current-grouping-key())}" store="true" index="true"/>
		</xsl:for-each-group>

		<!-- Apply profile indexing templates to child nodes --> 

		<xsl:apply-templates mode="index" select="*"/>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<xsl:template mode="index" match="gmd:resourceConstraints">
		<xsl:for-each select="*/mcp:attributionConstraints/gco:CharacterString">
			<Field name="attrConstr" string="{string(.)}" store="true" index="true" />
		</xsl:for-each>
		<xsl:for-each select="*/mcp:jurisdictionLink/gmd:URL">
			<Field name="jurisdictionLink" string="{string(.)}" store="true" index="true" />
		</xsl:for-each>
		<xsl:for-each select="*/mcp:licenseName/gco:CharacterString">
			<Field name="licenseName" string="{string(.)}" store="true" index="true" />
		</xsl:for-each>
		<xsl:for-each select="*/mcp:licenseLink/gmd:URL">
			<Field name="licenseLink" string="{string(.)}" store="true" index="true" />
		</xsl:for-each>
		<xsl:for-each select="*/gmd:otherCitationDetails/gco:CharacterString">
			<Field name="otherCitation" string="{string(.)}" store="true" index="true"/>
		</xsl:for-each>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
	<xsl:template mode="index" match="mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter">
		<xsl:for-each select="mcp:DP_DataParameter/mcp:parameterName/mcp:DP_Term">
			<xsl:variable name="term" select="mcp:term/*"/>
			<Field name="dataparam" string="{$term}" store="true" index="true"/>
			<xsl:if test="mcp:type/mcp:DP_TypeCode/@codeListValue='longName'">
				<Field name="longParamName" string="{$term}" store="true" index="true"/>
				<Field name="parameterUri" string="{.//mcp:vocabularyTermURL/gmd:URL[1]}" store="true" index="true"/>
			</xsl:if>
			<xsl:for-each select="mcp:vocabularyRelationship/mcp:DP_VocabularyRelationship">
				<Field name="vocabTerm" string="{mcp:vocabularyTermURL/gmd:URL}" store="true" index="true"/>
				<Field name="vocabTermList" string="{mcp:vocabularyListURL/gmd:URL}" store="true" index="true"/>
			</xsl:for-each>
		</xsl:for-each>

		<xsl:apply-templates mode="index" select="*"/>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		
	<xsl:template mode="index" match="mcp:revisionDate/*">

		<Field name="changeDate" string="{string(.)}" store="true" index="true"/>

		<xsl:apply-templates mode="index" select="*"/>
	</xsl:template>
		
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		
	<xsl:template mode="index" match="gmd:MD_Keywords">

		<xsl:variable name="thesaurusId" select="normalize-space(gmd:thesaurusName/*/gmd:identifier/*/gmd:code[starts-with(string(gmx:Anchor),'geonetwork.thesaurus')])"/>

		<xsl:if test="$thesaurusId!=''">
			<Field name="thesaurusName" string="{string($thesaurusId)}" store="true" index="true"/>
		</xsl:if>

		<!-- index keyword codes under lucene index field with name same
				 as thesaurus that contains the keyword codes -->

		<xsl:for-each select="gmd:keyword/*">
			<xsl:if test="name()='gmx:Anchor' and $thesaurusId!=''">
				<!-- expecting something like 
							    	<gmx:Anchor 
									  	xlink:href="http://localhost:8080/geonetwork/srv/en/xml.keyword.get?thesaurus=register.theme.urn:marine.csiro.au:marlin:keywords:standardDataType&id=urn:marine.csiro.au:marlin:keywords:standardDataTypes:concept:3510">CMAR Vessel Data: ADCP</gmx:Anchor>
				-->
	
				<xsl:variable name="keywordId">
					<xsl:for-each select="tokenize(@xlink:href,'&amp;')">
						<xsl:if test="starts-with(string(.),'id=')">
							<xsl:value-of select="substring-after(string(.),'id=')"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
	
				<xsl:if test="normalize-space($keywordId)!=''">
					<Field name="{$thesaurusId}" string="{replace($keywordId,'%23','#')}" store="true" index="true"/>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>

		<xsl:apply-templates mode="index" select="*"/>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<xsl:template mode="index" match="mcp:EX_TemporalExtent/gmd:extent/gml:TimePeriod">
		<xsl:variable name="times">
			<xsl:call-template name="newGmlTime">
				<xsl:with-param name="begin" select="gml:beginPosition|gml:begin/gml:TimeInstant/gml:timePosition"/>
				<xsl:with-param name="end" select="gml:endPosition|gml:end/gml:TimeInstant/gml:timePosition"/>
			</xsl:call-template>
		</xsl:variable>
		
		<Field name="tempExtentBegin" string="{lower-case(substring-before($times,'|'))}" store="true" index="true"/>
		<Field name="tempExtentEnd" string="{lower-case(substring-after($times,'|'))}" store="true" index="true"/>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<xsl:template mode="index" match="gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon">
		<xsl:variable name="wktCoords">
			<xsl:apply-templates mode="gml" select="*"/>
		</xsl:variable>
		<xsl:variable name="geom">POLYGON(<xsl:value-of select="java:replace(string($wktCoords), '\),$', ')')"/>)</xsl:variable>
		<Field name="geoPolygon" string="{string($geom)}" store="true" index="false"/>
	</xsl:template>

	<!-- gml mode - convert gml polygons into WKT -->

	<xsl:template mode="gml" match="gml:coordinates">
		<xsl:variable name="ts" select="string(@ts)"/>
		<xsl:variable name="cs" select="string(@cs)"/>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="java:takeUntil(java:toWktCoords(string(.),$ts,$cs), ';\Z')"/>
		<xsl:text>),</xsl:text>
	</xsl:template>

	<xsl:template mode="gml" match="gml:posList">
		<xsl:text>(</xsl:text>
		<xsl:value-of select="java:takeUntil(java:posListToWktCoords(string(.), string(@dimension)), ';\Z')"/>
		<xsl:text>),</xsl:text>
	</xsl:template>

	<xsl:template mode="gml" match="text()"/>
</xsl:stylesheet>
