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
<title>Http Session Test</title>
<script src="jquery-3.1.1.min.js"></script>


<script type="text/javascript">

   $( document ).ready(function() {
   var cp = '<%=request.getContextPath()%>';
   clrscr = function(){
		$("#result").val('');
	};

   print = function(s){
		$("#result").val($("#result").val()+ "" + s + '\n');
	    $("#result").attr("scrollTop",$("#result").attr("scrollHeight"));
   };

   $( document ).ajaxError(function(event, jqxhr, settings, e ) {
			if (e.message){
			  alert(e.message);
			  print(" Exception: \n\n" + e.message);
			  $( ".log" ).text( e.message );
		    }else{
			  alert(e);
			  print(" Exception: \n\n" + e);
			  $( ".log" ).text( e.message );
			}
    }); //eof ajax error

    refresh = function() {
		clrscr();
		var serviceUrl = $("#serviceUrl").val();
  	    $.ajax({
  	        type: "GET",
  	        //headers: {'Cookie' : document.cookie },
  	        cache: false,
  	      // NO setCookies option available, set cookie to document
  	      //setCookies: "lkfh89asdhjahska7al446dfg5kgfbfgdhfdbfgcvbcbc dfskljvdfhpl",
  	        crossDomain: true,
  	        xhrFields: {
  	         withCredentials: true
  	        },
	        url: serviceUrl,
	        jsonp: "callback",
	        dataType:"jsonp",
 	        success: function(response){
	           print(JSON.stringify(response.result,null,' '));
	        }
	    });//eof ajax
 	};

    save = function(){
	     var key = $("#attrKey").val();
	     var value = $("#attrValue").val();
	     $.ajax({
	        type:"GET",
	        //headers: {'Cookie' : document.cookie },
	        cache: false,
  	      // NO setCookies option available, set cookie to document
  	      //setCookies: "lkfh89asdhjahska7al446dfg5kgfbfgdhfdbfgcvbcbc dfskljvdfhpl",
  	        crossDomain: true,
  	        xhrFields: {
  	         withCredentials: true
  	        },
	        url: cp+"/rest/session/setAttribute",
	        jsonp: "callback",
	        dataType:"jsonp",
	        data: {
	          key: key,
	          value: value
	        },

	        success: function(response){
	           refresh();
	        }
	     });//eof ajax
 	};

 	remove = function(){
	     var key = $("#attrKey").val();
	     $.ajax({
	        type:"GET",
	        //headers: {'Cookie' : document.cookie },
	        cache: false,
 	      // NO setCookies option available, set cookie to document
 	      //setCookies: "lkfh89asdhjahska7al446dfg5kgfbfgdhfdbfgcvbcbc dfskljvdfhpl",
 	        crossDomain: true,
 	        xhrFields: {
 	         withCredentials: true
 	        },
	        url: cp+"/rest/session/removeAttribute",
	        jsonp: "callback",
	        dataType:"jsonp",
	        data: {
	          key: key
	        },

	        success: function(response){
	           refresh();
	        }
	     });//eof ajax
	};
	//initial on load 
 	refresh();
    });//eof dom ready!

</script>
</head>
<body>

	<h2>Http Session Test</h2>
	Session Id  :
	<b><%=request.getSession(true).getId()%></b><br>
	User Name :<b><%=request.getRemoteUser()%></b>
	 <%if (request.getRemoteUser() != null) { %>
	    &emsp; <a href="logout.jsp">click here to logout</a>
	 <%}else{%>
	    &emsp; <a href="secure.jsp">click here to login</a>
	 <%}%>
  <br>
  <hr>
  <label>Service:</label><input id="serviceUrl" type="text" size="60" 	value='<%=request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()	+ request.getRequestURI()%>rest/session/sessionInfo' />
  <input id="btnRefresh" type="button"	value="Print Session Values" onclick="refresh();" />
  <hr>
  <label>Key/Value:</label><input id="attrKey" type="text" size="20" title="Key" /> <input id="attrValue" type="text" size="20" title="Value" />
  <input id="btnSave" type="button" value="Save to <%=request.getServerName()%>:<%=request.getServerPort()%> Session"	onclick="save();" />
  <input id="btnRemove" type="button" value="Remove"	onclick="remove();" />
  <hr>
  <br/>Output
  <br />
  <textarea wrap="on" id="result" cols="120" rows="30"></textarea>
  <br />
</body>
</html>
