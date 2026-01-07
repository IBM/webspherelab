<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:process="http://www.ibm.com/websphere/appserver/schemas/5.0/process.xmi" 
    version="1.0" xmlns:xalan="http://xml.apache.org/xslt"
    xmlns:variables="http://www.ibm.com/websphere/appserver/schemas/5.0/variables.xmi"
	xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI">

   <!-- This file is used for transforming server.xml of default to server.xml of defaultXD.
        The transformation occurs on building the component WAS.profile.templates.nd and 
        WAS.profile.templates.management.  -->        

    <xsl:template match="/ | @* | node()">
        <xsl:copy>
    	    <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!--  Change the Name to defaultXD -->
    <xsl:template match="process:Server">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:attribute name="name">defaultXD</xsl:attribute>
            
            <xsl:apply-templates select="node()" />           
         </xsl:copy>
    </xsl:template>
    
    <xsl:template match="//threadPools[@xmi:id='ThreadPool_WC']">
        <xsl:copy>           
            <xsl:apply-templates select="@*" />
            <xsl:attribute name="maximumSize">175</xsl:attribute>
            <xsl:apply-templates select="node()" />      
        </xsl:copy>
    </xsl:template>    

    <xsl:template match="//transportChannels[@xmi:type='channelservice.channels:HTTPInboundChannel']">
        <xsl:copy>      
            <xsl:apply-templates select="@*" />
            <xsl:attribute name="maximumPersistentRequests">-1</xsl:attribute>
            <xsl:apply-templates select="node()" />      
        </xsl:copy>
    </xsl:template> 

    <xsl:template match="//jvmEntries[@xmi:id='JavaVirtualMachine_1']">
        <xsl:copy>      
            <xsl:apply-templates select="@*" />
            <xsl:attribute name="genericJvmArguments">-agentlib:HeapDetect64</xsl:attribute>
            <xsl:apply-templates select="node()" />      
        </xsl:copy>
    </xsl:template>     

</xsl:stylesheet>
