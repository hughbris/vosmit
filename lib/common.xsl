<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:exsl="http://exslt.org/common"
	xmlns:math="http://exslt.org/math"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	exclude-result-prefixes="exsl msxsl math"
	extension-element-prefixes="math exsl"
	xmlns=""
>

<xsl:include href="osmarender.xsl"/>

<!-- from http://dpcarlisle.blogspot.com/2007/05/exslt-node-set-function.html -->
<msxsl:script language="JScript" implements-prefix="exsl">
	this['node-set'] =  function (x) {
		return x;
	}
</msxsl:script>

<!-- ************************************************* -->
<!-- TODO: 
	Parked starting attempt to create a tiled image overlay, prefrably from any WMS server.
	The problem I am going to have here is that there's no concept of zoom levels in the source data. At a pinch, I can calculate an appropriate one (?) from the bounds.
	Let's think about it ...
-->

<xsl:template name="tilesOverlay">
	<!-- compile an overlay of tiles, cropping over edges may be an issue here -->
</xsl:template>

<!-- a lot of this based on http://svn.openstreetmap.org/applications/utils/downloading/tiles_by_bbox/get.pl by OJW - thank you for making it clearer :) -->
<!-- TODO: test output against Perl script output -->

<xsl:template name="deg2radians">
	<xsl:param name="deg" />
	<xsl:value-of select="$deg * 0.0174532925" />
</xsl:template>

<xsl:template name="projectF"> <!-- not sure what F is, probably the projection, copied form OJW's perl script -->
	<xsl:param name="lat" />
	<xsl:variable name="latRadians">
		<xsl:call-template name="deg2radians">
			<xsl:with-param name="deg" select="$lat" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="math:log(math:tan($latRadians)) + (1 div math:cos($latRadians))" />
</xsl:template>

<xsl:template name="lat2Yref">
	<xsl:param name="lat" />
	<xsl:variable name="Ylimit">
		<xsl:call-template name="projectF">
			<xsl:with-param name="lat">85.0511</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="projectedLat">
		<xsl:call-template name="projectF">
			<xsl:with-param name="lat" select="$lat" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="($Ylimit - $projectedLat) div (2 * $Ylimit)" />
</xsl:template>

<xsl:template name="lon2Xref">
	<xsl:param name="lon" />
	<xsl:value-of select="($lon + 180) div 360" />
</xsl:template>

</xsl:transform>
