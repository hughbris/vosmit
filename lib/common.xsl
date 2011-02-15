<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:exslt="http://exslt.org/common"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	exclude-result-prefixes="exslt msxsl"
	xmlns=""
>

<!-- from http://dpcarlisle.blogspot.com/2007/05/exslt-node-set-function.html -->
<msxsl:script language="JScript" implements-prefix="exslt">
	this['node-set'] =  function (x) {
		return x;
	}
</msxsl:script>

<xsl:include href="osmarender.xsl"/>

</xsl:transform>
