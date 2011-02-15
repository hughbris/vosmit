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

<xsl:transform version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:svg="http://www.w3.org/2000/svg"
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

<!-- <xsl:include href="lib/common.xsl"/> -->

<xsl:variable name="maxHeight" select="1" /> <!-- degrees -->
<xsl:variable name="maxWidth" select="1" />

<xsl:param name="left" /> <!-- xs:type, value constraints --> <!-- 153.022926 -->
<xsl:param name="bottom" /> <!-- -27.53328 -->
<xsl:param name="right" /> <!-- 153.037292 -->
<xsl:param name="top" /> <!-- -27.527372 -->

<!-- TODO: do a bit of cleansing, checking on bbox here, spitting warnings and choking as appropriate -->
<!-- OK, the API will return 400 bad request, but I think I'll check for these anyway -->
<!-- TODO: check type -->
<xsl:variable name="validExtents">
	<xsl:call-template name="checkBoundaryExtents" />
</xsl:variable>

<xsl:variable name="bbox.left" select="$left" /> <!-- must be between -180 and 180 and < $right and not too distant from $right -->
<xsl:variable name="bbox.bottom" select="$bottom" /> <!-- must be between -90 and 90 and < $top and not too distant from $top -->
<xsl:variable name="bbox.right" select="$right" /> <!-- must be between -180 and 180 and > $left  and not too distant from $left -->
<xsl:variable name="bbox.top" select="$top" /> <!-- must be between -90 and 90 and > $bottom  and not too distant from $bottom -->

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

<xsl:template match="/osm">
	<svg:svg>
		<!-- insert metadata here: src, title, coverage (duh) etc -->
		<svg:circle r="50"/> <!-- FIXME: stub -->
		<xsl:comment>
			<xsl:value-of select="$src" />
		</xsl:comment>
	</svg:svg>
</xsl:template>

<xsl:template name="checkBoundaryExtents">
	<xsl:choose>
		<xsl:when test="$left and $right and $top and $bottom">
			<xsl:if test="$left &lt; -180 or $left > 180">
				<xsl:message terminate="yes">Fatal: left boundary parameter value (<xsl:value-of select="$left" />) must be between -180 and 180</xsl:message>
			</xsl:if>
			<xsl:if test="$right &lt; -180 or $right > 180">
				<xsl:message terminate="yes">Fatal: right boundary parameter value (<xsl:value-of select="$right" />) must be between -180 and 180</xsl:message>
			</xsl:if>
			<xsl:if test="(1 - 2*($right &lt; 0) * $right) - (1 - 2*($left &lt; 0) * $left) > $maxWidth"> <!-- FIXME: assuming $left is < $right here -->
				<xsl:message terminate="yes">Fatal: left and right boundaries exceed the maximum degree distance (<xsl:value-of select="$maxWidth" />) allowed</xsl:message>
			</xsl:if>
			<xsl:if test="$bottom &lt; -90 or $bottom > 90">
				<xsl:message terminate="yes">Fatal: bottom boundary parameter value (<xsl:value-of select="$bottom" />) must be between -90 and 90</xsl:message>
			</xsl:if>
			<xsl:if test="$top &lt; -90 or $top > 90">
				<xsl:message terminate="yes">Fatal: top boundary parameter value (<xsl:value-of select="$top" />) must be between -90 and 90</xsl:message>
			</xsl:if>
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:transform>

