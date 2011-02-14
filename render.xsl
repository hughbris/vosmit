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
	xmlns=""
>
<!-- the moronic null namespace is OSM's, thank you -->

<xsl:output
	method="xml"
	indent="yes"
	encoding="utf-8"
	omit-xml-declaration="no"
/>

<!-- http://wiki.openstreetmap.org/wiki/API_v0.6 -->

<xsl:variable name="api.endpoint">http://api.openstreetmap.org/api/0.6</xsl:variable>
<!-- <xsl:variable name="api.endpoint">http://api06.dev.openstreetmap.org/api/0.6</xsl:variable> -->

<xsl:include href="lib/common.xsl"/>

<xsl:param name="left" /> <!-- xs:type, value constraints --> <!-- 153.022926 -->
<xsl:param name="bottom" /> <!-- -27.53328 -->
<xsl:param name="right" /> <!-- 153.037292 -->
<xsl:param name="top" /> <!-- -27.527372 -->

<!-- TODO: do a bit of cleansing, checking on bbox here, spitting warnings and choking as appropriate -->
<xsl:variable name="bbox.left" select="$left" />
<xsl:variable name="bbox.bottom" select="$bottom" />
<xsl:variable name="bbox.right" select="$right" />
<xsl:variable name="bbox.top" select="$top" />

<!-- serialise the bbox querystring value as the API would have it -->
<xsl:variable
	name="bbox.queryvalue"
	select="concat (
		$bbox.left, ',' ,
		$bbox.bottom, ',' ,
		$bbox.right, ',' ,
		$bbox.top
		)
	"
/>

<xsl:param name="src" select="concat($api.endpoint , '/map?bbox=' , $bbox.queryvalue)" /> <!-- this way, a provided $src will trump any bbox params provided -->
<!-- http://api.openstreetmap.org/api/0.6/map?bbox=153.022926,-27.53328,153.037292,-27.527372 -->

<xsl:variable name="data" select="document($src)" />

<xsl:variable name="dimensions">
	<xsl:call-template name="getDimensions">
		<xsl:with-param name="bounds" select="$data/osm/bounds" />
		<xsl:with-param name="minimumMapWidth" select="0.5" />
		<xsl:with-param name="minimumMapHeight" select="0.5" />
	</xsl:call-template>
</xsl:variable>

<xsl:variable name="centreX" select="round($dimensions/config:dimensions/config:svgWidth div 2)" />
<xsl:variable name="centreY" select="round($dimensions/config:dimensions/config:svgHeight div 2)" />

<xsl:template match="/osm">
	<svg:svg
		width="{$dimensions/config:dimensions/config:svgWidth}px"
		height="{$dimensions/config:dimensions/config:svgHeight}px"
	>
		<!-- insert metadata here: src, title, coverage (duh) etc -->
		<svg:circle r="50" cx="{$centreX}" cy="{$centreY}" /> <!-- FIXME: stub -->
		<xsl:comment>
			Src: <xsl:value-of select="$src" />.
			Bounds minlat: <xsl:value-of select="$data/osm/bounds/@minlat" />.
			projection: <xsl:value-of select="$dimensions/config:dimensions/config:projection" />.
			svgWidth: <xsl:value-of select="$dimensions/config:dimensions/config:svgWidth" />.
			svgHeight: <xsl:value-of select="$dimensions/config:dimensions/config:svgHeight" />.
			Km: <xsl:value-of select="$dimensions/config:dimensions/config:km" />.
		</xsl:comment>
	</svg:svg>
</xsl:template>

</xsl:transform>

