<%@ page errorPage="Error.jsp" %>
<%@ include file="Header.jsp" %>

<table id="ProjectFeedbackTable" border="0">
  <tr><th class="feedback"><c:out value="${ProjectFeedback}"/></th></tr>
</table>

<%-- Single line JSP comment --%>
<table id="ProjectResultTable" border="0">
  <tr>
    <th class="data" width="20%">Name:</th>
    <td><c:out value="${Project.name}"/></td>
  </tr>
  <tr>
     <th class="data">Start day:</th>
     <td><c:out value="${Project.startDay}"/></td>
  </tr>
  <tr>
     <th class="data">End day:</th>
     <td>
       <c:choose>
         <c:when test="${empty Project.endDay}">
           <c:out value="Undetermined"/>
         </c:when>
         <c:otherwise>
           <c:out value="${Project.endDay}"/>
         </c:otherwise>
       </c:choose>
     </td>
  </tr>

  <%-- Multi line comment
  <tr>
     <th class="data">Member emails:</th>
     <td>
        <c:forEach var="member" items="${Project.members}">
          <c:out value="${member.userEmail} "/>
        </c:forEach>
     </td>
  </tr>
  --%>

  <tr>
     <th class="data">Workspaces:</th>
     <td>
        <c:forEach var="workspace" items="${Project.workspaceSetCopy}">
           <c:out value="${workspace} "/>
        </c:forEach>
     </td>
  </tr>

  <tr>
     <th class="data">Description:</th>
     <td>
        <c:out value="${Project.description}"/>
     </td>
  </tr>
</table>

<table>
<tr>
   <td>
     <form id="ModifyProjectForm" action="controller" method="POST">
       <input type="hidden" name="Command" value="ModifyProject">
       <input type="hidden" name="Key" value="<c:out value="${user.userKey}"/>">
       <input type=hidden name="ProjectName" value="<c:out value="${Project.name}"/>" />
       <input type="submit" name="Submit" value="Modify">
     </form>
   </td>
   <td>
     <form id="ManageProjectForm" action="controller" method="POST">
       <input type="hidden" name="Command" value="ManageProject">
       <input type="hidden" name="Key" value="<c:out value="${user.userKey}"/>">
       <input type="submit" name="Submit" value="Return to project management">
     </form>
   </td>
</tr>
</table>