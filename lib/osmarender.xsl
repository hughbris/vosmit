<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:config="tag:osm.org,2010-09-30:config"
	xmlns=""
>

<!-- 
This module contains code adapted but pretty well copied from Osmarender: http://trac.openstreetmap.org/browser/applications/rendering/osmarender. Please refer there for any licensing information.
-->

<xsl:template match="bounds" mode="dimensions">
	<xsl:param name="minimumMapWidth" />
	<xsl:param name="minimumMapHeight" />
	<xsl:param name="settings" /> <!-- not in use -->
	<xsl:param name="scale" select="1" />

	<!-- and these to 0 for the same reason -->
	<xsl:variable name="extraWidth" select="0" />
	<xsl:variable name="marginaliaTopHeight" select="0" />
	<xsl:variable name="marginaliaBottomHeight" select="0" />

	<config:dimensions>
		<!-- Derive the latitude of the middle of the map -->
		<xsl:variable name="middleLatitude" select="(@maxlat + @minlat) div 2"/>
		<!--woohoo lets do trigonometry in xslt -->
		<!--convert latitude to radians -->
		<xsl:variable name="latr" select="$middleLatitude * 3.1415926 div 180"/>
		<!--taylor series: two terms is 1% error at lat<68 and 10% error lat<83. we probably need polar projection by then -->
		<xsl:variable name="coslat" select="1 - ($latr * $latr) div 2 + ($latr * $latr * $latr * $latr) div 24"/>
		<xsl:variable name="projection" select="1 div $coslat"/>

		<config:projection>
			<xsl:value-of select="$projection" />
		</config:projection>

		<xsl:variable name="km" select="(0.0089928*$scale*10000*$projection)"/>

		<config:km>
			<xsl:value-of select="$km" />
		</config:km>

		<xsl:variable name="dataWidth" select="(number(@maxlon)-number(@minlon))*10000*$scale"/>
		<xsl:variable name="dataHeight" select="(number(@maxlat)-number(@minlat))*10000*$scale*$projection"/>

		<xsl:variable name="documentWidth">
			<xsl:choose>
				<xsl:when test="$dataWidth &gt; (number($minimumMapWidth) * $km)">
					<xsl:value-of select="$dataWidth"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="number($minimumMapWidth) * $km"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="documentHeight">
			<xsl:choose>
				<xsl:when test="$dataHeight &gt; (number($minimumMapHeight) * $km)">
					<xsl:value-of select="$dataHeight"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="number($minimumMapHeight) * $km"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- I don't know exactly what these are the width and height of, or in which units, but faithfully copying -->
		<xsl:variable name="width" select="($documentWidth div 2) + ($dataWidth div 2)"/>
		<xsl:variable name="height" select="($documentHeight div 2) + ($dataHeight div 2)"/>

		<config:width>
			<xsl:value-of select="$width" />
		</config:width>
		<config:height>
			<xsl:value-of select="$height" />
		</config:height>

		<xsl:variable name="svgWidth" select="ceiling($documentWidth + $extraWidth)"/>
		<xsl:variable name="svgHeight" select="ceiling($documentHeight + $marginaliaTopHeight + $marginaliaBottomHeight)"/>

		<config:svgWidth>
			<xsl:value-of select="$svgWidth" />
		</config:svgWidth>
		<config:svgHeight>
			<xsl:value-of select="$svgHeight" />
		</config:svgHeight>

	</config:dimensions>

<!--  svg:svg attributes:
	baseProfile="{$svgBaseProfile}"
	width="{$svgWidth}px"
	height="{$svgHeight}px"
	preserveAspectRatio="none"
	viewBox="{-$extraWidth div 2} {-$extraHeight div 2} {$svgWidth} {$svgHeight}"
-->
</xsl:template>

</xsl:transform>
