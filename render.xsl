<?xml version="1.0" encoding="utf-8"?>

<!--

    description: refer README.txt for now

	TODO: immediate plans:
	- filter/correct params
	- get correct proportions for canvas
	- draw nodes as basic lines
	- draw ways as basic lines
	- play with photo underlays and compare
	- experiment with customisation frameworks (css, icons etc)
	- play with interactivity
	- play with put/post

-->

<xsl:transform version="1.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:config="tag:osm.org,2010-09-30:config"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="exsl #default config"
	extension-element-prefixes="exsl"
	xmlns=""
>
<!-- FIXME: is there a doctype/namespace where svg+rdfa will validate? -->

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

<!-- will hardcode $scale to 1 until I understand better what it's scaling -->
<xsl:param name="scale" select="1" />

<xsl:variable name="dimensionsDocument">
	<xsl:apply-templates select="/osm/bounds" mode="dimensions">
		<xsl:with-param name="minimumMapWidth" select="$minimumMapWidth" />
		<xsl:with-param name="minimumMapHeight" select="$minimumMapHeight" />
		<xsl:with-param name="scale" select="$scale" />
	</xsl:apply-templates>
</xsl:variable>
<xsl:variable name="dimensions" select="exsl:node-set($dimensionsDocument)/*" />

<!-- some convenience variables -->
<xsl:variable name="bound.north" select="/osm/bounds/@maxlat" />
<xsl:variable name="bound.south" select="/osm/bounds/@minlat" />
<xsl:variable name="bound.east" select="/osm/bounds/@maxlon" />
<xsl:variable name="bound.west" select="/osm/bounds/@minlon" />

<xsl:variable name="centreX" select="round($dimensions/config:svgWidth div 2)" />
<xsl:variable name="centreY" select="round($dimensions/config:svgHeight div 2)" />

<xsl:template match="/osm">
	<svg:svg
		width="{$dimensions/config:svgWidth}px"
		height="{$dimensions/config:svgHeight}px"
	>

		<!-- FIXME: try to farm this out to an external file or do something clever to import it so it's not embedded here (actually that's really important) -->
		<svg:style type="text/css">
			.node.test {
				fill: red;
			}
			.label.test {
				fill: blue;
			}
			.way .line.test {
				fill: none;
				stroke: pink;
			}
			.way .label.test {
				font-size: 6px;
				font-variant: small-caps;
			}
		</svg:style>

		<!-- insert metadata here: src, title, coverage (duh) etc -->

		<!-- <xsl:apply-templates select="node" mode="testing" /> --> <!-- test predicate [@changeset='655764'] -->

		<svg:defs>
			<xsl:apply-templates select="way" mode="defs" />
		</svg:defs>

		<xsl:apply-templates select="way" mode="testing" /> <!-- test predicate [@changeset='3756370'] -->

		<!-- FIXME: debug output -->
		<xsl:comment>
			Bounds minlat: <xsl:value-of select="$bound.south" />.
			projection: <xsl:value-of select="$dimensions/config:projection" />.
			svgWidth: <xsl:value-of select="$dimensions/config:svgWidth" />.
			svgHeight: <xsl:value-of select="$dimensions/config:svgHeight" />.
			Km: <xsl:value-of select="$dimensions/config:km" />.
		</xsl:comment>
	</svg:svg>
</xsl:template>

<xsl:template match="node" mode="testing">
	<!-- position calcs shameless adapted from osma -->
    <xsl:variable name="posX" select="$dimensions/config:width - ( ($bound.east - @lon ) * 10000 * $scale )" />
    <xsl:variable name="posY" select="$dimensions/config:height + ( ($bound.south - @lat) * 10000 * $scale * $dimensions/config:projection )" />
	<svg:circle class="node test ed{@changeset}" id="nd{@id}" cx="{$posX}" cy="{$posY}" r="1" />
	<!--
	<svg:text class="label test" x="{number($posX)+1}" y="{$posY}">
		<xsl:value-of select="@lat" />
		<xsl:text>,</xsl:text>
		<xsl:value-of select="@lon" />
	</svg:text>
	-->
</xsl:template>

<xsl:template match="way/nd" mode="path">
	<!-- replace this lookup with a key lookup -->
	<xsl:variable name="ref" select="@ref" />
	<xsl:variable name="node" select="/osm/node[@id=$ref]" />
	<xsl:text> </xsl:text>
    <xsl:value-of select="round($dimensions/config:width - ( ($bound.east - $node/@lon ) * 10000 * $scale ))" />
	<xsl:text>,</xsl:text>
    <xsl:value-of select="round($dimensions/config:height + ( ($bound.south - $node/@lat) * 10000 * $scale * $dimensions/config:projection ))" />
</xsl:template>

<xsl:template match="way" mode="defs">
	<!-- position calcs shameless adapted from osma -->
	<!--
		Would prefer these calcs were coded in one place, also want to make sure they aren't run more than once per node.
		Ideally, would build a calculated index for them but can't seem to do that with xsl:key.
		svg:use from svg:defs (like for ways) is not an option for nodes because they may be marked up using several kinds of svg elements (circle, line, square etc) all of which use different co-ordinate attributes.
		May be that positions for nodes aren't called relatively often enough to be a concern.
		Would need XSLT 2.0 to make a custom XPath(-style?) function, but a template will do it in 1.x, albeit verbosely.
	-->
    <xsl:variable name="posX" select="$dimensions/config:width - ( ($bound.east - @lon ) * 10000 * $scale )" />
    <xsl:variable name="posY" select="$dimensions/config:height + ( ($bound.south - @lat) * 10000 * $scale * $dimensions/config:projection )" />
	<svg:path id="obj{@id}">
		<xsl:attribute name="d">
			<xsl:text>M</xsl:text>
			<xsl:apply-templates select="nd" mode="path" />
		</xsl:attribute>
	</svg:path>
</xsl:template>

<xsl:template match="way" mode="testing">
	<svg:g id="wy{@id}" class="way">
		<!-- TODO: we want to associate the OSM object URI here for sure -->
		<!-- TODO: further rdfa metadata here from tags -->
		<svg:use xlink:href="#obj{@id}" class="line test ed{@changeset}" />
		<!-- <xsl:apply-templates select="tag[@k='name']" mode="label" /> --> <!-- label -->
	</svg:g>
</xsl:template>

<xsl:template match="way/tag" mode="label">
	<!-- TODO: lots: offset it/overlay it, scale it -->
	<svg:text class="label test" about="#wy{../@id}">
		<svg:textPath xlink:href="#obj{../@id}" property="dcterms:title"> <!-- FIXME: what knowledge I once had of RDFa and its context rules are out the window, this is likely wrong -->
			<xsl:value-of select="@v" />
		</svg:textPath>
	</svg:text>
</xsl:template>

</xsl:transform>

