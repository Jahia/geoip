<%@page import="com.maxmind.geoip.*"%>
<%@ page import="javax.jcr.Value" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<jcr:nodeProperty node="${currentNode}" name="j:localhostTestAddress" var="localhostTestAddress"/>
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
<c:set var="jahiaComponentExpression" value="${resolvedCountry.code}" scope="request" />
<c:if test="${renderContext.editMode}">GeoIP country for remote IP address ${request.remoteAddr} (= ${jahiaComponentExpression})</c:if>