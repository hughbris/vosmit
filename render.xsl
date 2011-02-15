<?xml version="1.0" encoding="utf-8"?>

<!--

    description: refer README.txt for now

	TODO: immediate plans:
	- spit out params
	- filter/correct params
	- get correct proportions for canvas
	- draw ways as basic lines
	- play with interactivity
	- play with put/post
	- play with photo underlays

-->

<xsl:transform version="1.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:config="tag:osm.org,2010-09-30:config"
	xmlns:exslt="http://exslt.org/common"
	exclude-result-prefixes="exslt #default config"
	xmlns=""
>

<!-- the moronic null namespace is OSM's, thank you -->
<!-- <xsl:namespace-alias stylesheet-prefix="svg" result-prefix="#default"/> -->

<xsl:output
	method="xml"
	indent="yes"
	encoding="utf-8"
	omit-xml-declaration="no"
/>

<!-- don't think I need these any more for read-only static views -->
<!-- http://wiki.openstreetmap.org/wiki/API_v0.6 -->
<!-- <xsl:variable name="api.endpoint">http://api.openstreetmap.org/api/0.6</xsl:variable> -->
<!-- <xsl:variable name="api.endpoint">http://api06.dev.openstreetmap.org/api/0.6</xsl:variable> -->
<!-- http://api.openstreetmap.org/api/0.6/map?bbox=153.022926,-27.53328,153.037292,-27.527372 -->

<xsl:include href="lib/common.xsl"/>

<!-- **************************** -->
<!-- osma settings, documented at http://wiki.openstreetmap.org/wiki/Osmarender/Options -->

<!-- "These settings override the normal bounding box settings to set the minimum size of the map canvas. The size is specified in kilometers, which is also the size of the grid boxes. If the map to be rendered is smaller than these settings it will be centered on the canvas." -->
<xsl:param name="minimumMapWidth" select="3" /> <!-- kilometres -->
<xsl:param name="minimumMapHeight" select="3" /> <!-- kilometres -->
<!-- **************************** -->

<xsl:variable name="dimensionsDocument">
	<xsl:apply-templates select="/osm/bounds" mode="dimensions">
		<xsl:with-param name="minimumMapWidth" select="$minimumMapWidth" />
		<xsl:with-param name="minimumMapHeight" select="$minimumMapHeight" />
	</xsl:apply-templates>
</xsl:variable>

<xsl:variable name="dimensions" select="exslt:node-set($dimensionsDocument)/*" />

<xsl:variable name="centreX" select="round($dimensions/config:svgWidth div 2)" />
<xsl:variable name="centreY" select="round($dimensions/config:svgHeight div 2)" />

<xsl:template match="/osm">
	<svg:svg
		width="{$dimensions/config:svgWidth}px"
		height="{$dimensions/config:svgHeight}px"
	>

		<!-- insert metadata here: src, title, coverage (duh) etc -->
		<svg:circle r="50" cx="{$centreX}" cy="{$centreY}" /> <!-- FIXME: stub -->
		<xsl:comment>
			Bounds minlat: <xsl:value-of select="/osm/bounds/@minlat" />.
			projection: <xsl:value-of select="$dimensions/config:projection" />.
			svgWidth: <xsl:value-of select="$dimensions/config:svgWidth" />.
			svgHeight: <xsl:value-of select="$dimensions/config:svgHeight" />.
			Km: <xsl:value-of select="$dimensions/config:km" />.
		</xsl:comment>
	</svg:svg>
</xsl:template>

</xsl:transform>

