<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="cache-control" content="max-age=0" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="expires" content="0" />
<meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT" />
<meta http-equiv="pragma" content="no-cache" />
<title>Login</title>

</head>
<body>
<%
  if(request.getRemoteUser() != null){
		response.sendRedirect(request.getContextPath());
	}else{
%>
<h1>Login</h1>
<form method="post" action='<%= response.encodeURL("j_security_check")%>'>
    <table>
        <tr>
            <td>username (demouser1,demouser2)</td>
            <td><input name="j_username" type="text"></td>
        </tr>
        <tr>
            <td>password (redhat1!)</td>
            <td><input name="j_password" type="password"></td>
        </tr>
    </table>
    <div>
        <input name="submit" type="submit" value="Login">
        <input name="reset" type="reset" value="Reset">
    </div>
</form>
<br>
	
<% } %>
</body>
</html>
