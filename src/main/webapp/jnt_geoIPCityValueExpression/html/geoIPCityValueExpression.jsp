<%@page import="com.maxmind.geoip.*"%>
<%@ page import="javax.jcr.Value" %>
<%@ page import="org.jahia.services.render.RenderContext" %>
<%@ page import="java.io.File" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<jcr:nodeProperty node="${currentNode}" name="j:localhostTestAddress" var="localhostTestAddress"/>
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
<c:set var="jahiaComponentExpression" value="${resolvedLocation.city}" scope="request" />
<c:if test="${renderContext.editMode}">GeoIP city for remote IP address ${request.remoteAddr} (= ${jahiaComponentExpression})</c:if>