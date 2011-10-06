<%@page import="com.maxmind.geoip.*"%>
<%@ page import="javax.jcr.Value" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>

<jcr:nodeProperty node="${currentNode}" name="j:country" var="countryToMatch"/>
<jcr:nodeProperty node="${currentNode}" name="j:localhostTestAddress" var="localhostTestAddress"/>

<template:addResources type="css" resources="geoip.css"/>

<c:if test="${renderContext.editMode}">
<div class="geoipbox">
<h4><fmt:message key="label.ifGeoIPCountryArea"/></h4>
    <p><fmt:message key="label.ifGeoIPCountry.componentDescription"/></p>
</div>
</c:if>

<%
    String dbFile = application.getRealPath("/modules/geoip/META-INF/GeoIP.dat");
    LookupService lookupService = new LookupService(dbFile,LookupService.GEOIP_MEMORY_CACHE);
    String remoteAddr = request.getRemoteAddr();
    if ("127.0.0.1".equals(remoteAddr) ||
        "0:0:0:0:0:0:0:1".equals(remoteAddr) ||
        remoteAddr.startsWith("192.168.1") ||
        remoteAddr.startsWith("10.0")) {
        remoteAddr = ((Value) pageContext.findAttribute("localhostTestAddress")).getString();
    }
    Country country = lookupService.getCountry(remoteAddr);
    System.out.println("Resolved "+remoteAddr+" to country code=" + country.getCode() + " name=" + country.getName());
    pageContext.setAttribute("resolvedCountry", country);
%>

<c:choose>
    <c:when test="${renderContext.editMode}">
        If user's country code equals ${countryToMatch.string} then display
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
        <c:if test="${resolvedCountry.code == countryToMatch.string}">
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