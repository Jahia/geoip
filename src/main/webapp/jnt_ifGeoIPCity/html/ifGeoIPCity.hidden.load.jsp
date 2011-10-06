<%@page import="com.maxmind.geoip.*"%>
<%@ page import="javax.jcr.Value" %>
<%@ page import="java.io.File" %>
<%@ page import="org.jahia.services.render.RenderContext" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>

<jcr:nodeProperty node="${currentNode}" name="j:city" var="cityToMatch"/>
<jcr:nodeProperty node="${currentNode}" name="j:localhostTestAddress" var="localhostTestAddress"/>

<template:addResources type="css" resources="geoip.css"/>

<c:if test="${renderContext.editMode}">
<div class="geoipbox">
<h4><fmt:message key="label.ifGeoIPCityArea"/></h4>
    <p><fmt:message key="label.ifGeoIPCity.componentDescription"/></p>
</div>
</c:if>

<%
    String dbFile = application.getRealPath("/modules/geoip/META-INF/GeoLiteCity.dat");
    File dbFileFile = new File(dbFile);
    if (dbFileFile.exists()) {
        LookupService lookupService = new LookupService(dbFile,LookupService.GEOIP_MEMORY_CACHE);
        String remoteAddr = request.getRemoteAddr();
        if ("127.0.0.1".equals(remoteAddr) ||
            "0:0:0:0:0:0:0:1".equals(remoteAddr) ||
            remoteAddr.startsWith("192.168.1") ||
            remoteAddr.startsWith("10.0")) {
            remoteAddr = ((Value) pageContext.findAttribute("localhostTestAddress")).getString();
        }
        Location location = lookupService.getLocation(remoteAddr);
        System.out.println("Resolved "+remoteAddr+" to city=" + location.city +
                " area code=" + location.area_code +
                " longitude=" + location.longitude +
                " latitude=" + location.latitude +
                " postal code=" + location.postalCode +
                " region=" + location.region +
                " metro code=" + location.metro_code +
                " dma code=" + location.dma_code +
                " country code=" + location.countryCode +
                " country name=" + location.countryName);
        pageContext.setAttribute("resolvedLocation", location);
    } else {
        RenderContext renderContext = (RenderContext) pageContext.findAttribute("renderContext");
        if (renderContext.isEditMode()) {
            out.println("Please install GeoLiteCity database in location " + dbFile);
        }
        pageContext.setAttribute("resolvedLocation", null);
    }
%>

<c:choose>
    <c:when test="${renderContext.editMode}">
        If user's city equals ${cityToMatch.string} then display
        <c:set var="facetParamVarName" value="N-${currentNode.name}"/>
        <%-- list mode --%>
        <c:choose>
            <c:when test="${not empty param[facetParamVarName]}">
                <query:definition var="listQuery" >
                    <query:selector nodeTypeName="nt:base"/>
                    <c:set var="descendantNode" value="${fn:substringAfter(currentNode.realNode.path,'/sites/')}"/>
                    <c:set var="descendantNode" value="${fn:substringAfter(descendantNode,'/')}"/>
                    <query:descendantNode path="/sites/${renderContext.site.name}/${descendantNode}"/>
                </query:definition>
                <c:set target="${moduleMap}" property="listQuery" value="${listQuery}"/>
            </c:when>
            <c:otherwise>
                <c:set target="${moduleMap}" property="editable" value="true" />
                <c:set target="${moduleMap}" property="currentList" value="${jcr:getChildrenOfType(currentNode, jcr:getConstraints(currentNode))}" />
                <c:set target="${moduleMap}" property="end" value="${fn:length(moduleMap.currentList)}" />
                <c:set target="${moduleMap}" property="listTotalSize" value="${moduleMap.end}" />
            </c:otherwise>
        </c:choose>
    </c:when>

    <c:otherwise>
        <c:if test="${resolvedLocation.city == cityToMatch.string}">
            <c:set var="facetParamVarName" value="N-${currentNode.name}"/>
            <%-- list mode --%>
            <c:choose>
                <c:when test="${not empty param[facetParamVarName]}">
                    <query:definition var="listQuery" >
                        <query:selector nodeTypeName="nt:base"/>
                        <c:set var="descendantNode" value="${fn:substringAfter(currentNode.realNode.path,'/sites/')}"/>
                        <c:set var="descendantNode" value="${fn:substringAfter(descendantNode,'/')}"/>
                        <query:descendantNode path="/sites/${renderContext.site.name}/${descendantNode}"/>
                    </query:definition>
                    <c:set target="${moduleMap}" property="listQuery" value="${listQuery}"/>
                </c:when>
                <c:otherwise>
                    <c:set target="${moduleMap}" property="editable" value="true" />
                    <c:set target="${moduleMap}" property="currentList" value="${jcr:getChildrenOfType(currentNode, jcr:getConstraints(currentNode))}" />
                    <c:set target="${moduleMap}" property="end" value="${fn:length(moduleMap.currentList)}" />
                    <c:set target="${moduleMap}" property="listTotalSize" value="${moduleMap.end}" />
                </c:otherwise>
            </c:choose>
        </c:if>
    </c:otherwise>
</c:choose>