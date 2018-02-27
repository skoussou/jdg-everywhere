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
<title>JDG Client</title>
<script src="jquery-3.1.1.min.js"></script>


<script type="text/javascript">

   $( document ).ready(function() {
        var cp = '<%=request.getContextPath()%>';
		clrscr = function() {
			$("#result").val('');
		};

		print = function(s) {
			$("#result").val($("#result").val() + "" + s + '\n');
			$("#result").attr("scrollTop", $("#result").attr("scrollHeight"));
		};

		$(document).ajaxError(function(event, jqxhr, settings, e) {
			if (e.message) {
				alert(e.message);
				print(" Exception: \n\n" + e.message);
				$(".log").text(e.message);
			} else {
				alert(e);
				print(" Exception: \n\n" + e);
				$(".log").text(e.message);
			}
		}); //eof ajax error

		stats = function() {
			clrscr();
			var cacheHost = $("#cacheHost").val();
			var cachePort = $("#cachePort").val();
			var cacheName = $("#cacheName").val();
			$.ajax({
				type : "GET",
				//headers: {'Cookie' : document.cookie },
				cache : false,
				// NO setCookies option available, set cookie to document
				//setCookies: "lkfh89asdhjahska7al446dfg5kgfbfgdhfdbfgcvbcbc dfskljvdfhpl",
				crossDomain : true,
				xhrFields : {
					withCredentials : true
				},
				url : cp + "/rest/cache/stats",
				jsonp : "callback",
				dataType : "jsonp",
				data : {
					cacheHost : cacheHost,
					cachePort : cachePort,
					cacheName : cacheName
				},
				success : function(response) {
					print(JSON.stringify(response.result, null, ' '));
				}
			});//eof ajax
		};

		values = function() {
			clrscr();
			var cacheHost = $("#cacheHost").val();
			var cachePort = $("#cachePort").val();
			var cacheName = $("#cacheName").val();
			$.ajax({
				type : "GET",
				//headers: {'Cookie' : document.cookie },
				cache : false,
				// NO setCookies option available, set cookie to document
				//setCookies: "lkfh89asdhjahska7al446dfg5kgfbfgdhfdbfgcvbcbc dfskljvdfhpl",
				crossDomain : true,
				xhrFields : {
					withCredentials : true
				},
				url : cp + "/rest/cache/values",
				jsonp : "callback",
				dataType : "jsonp",
				data : {
					cacheHost : cacheHost,
					cachePort : cachePort,
					cacheName : cacheName
				},
				success : function(response) {
					print(JSON.stringify(response.result, null, ' '));
				}
			});//eof ajax
		};

		save = function() {
			clrscr();
			var key = $("#attrKey").val();
			var value = $("#attrValue").val();
			var cacheHost = $("#cacheHost").val();
			var cachePort = $("#cachePort").val();
			var cacheName = $("#cacheName").val();
			$.ajax({
				type : "GET",
				//headers: {'Cookie' : document.cookie },
				cache : false,
				// NO setCookies option available, set cookie to document
				//setCookies: "lkfh89asdhjahska7al446dfg5kgfbfgdhfdbfgcvbcbc dfskljvdfhpl",
				crossDomain : true,
				xhrFields : {
					withCredentials : true
				},
				url : cp + "/rest/cache/save",
				jsonp : "callback",
				dataType : "jsonp",
				data : {
					key : key,
					value : value,
					cacheHost : cacheHost,
					cachePort : cachePort,
					cacheName : cacheName
				},
				success : function(response) {
					//print(JSON.stringify(response.result, null, ' '));
					values();
				}
			});//eof ajax
		};
		remove = function() {
			clrscr();
			var key = $("#attrKey").val();
			var cacheHost = $("#cacheHost").val();
			var cachePort = $("#cachePort").val();
			var cacheName = $("#cacheName").val();
			$.ajax({
				type : "GET",
				//headers: {'Cookie' : document.cookie },
				cache : false,
				// NO setCookies option available, set cookie to document
				//setCookies: "lkfh89asdhjahska7al446dfg5kgfbfgdhfdbfgcvbcbc dfskljvdfhpl",
				crossDomain : true,
				xhrFields : {
					withCredentials : true
				},
				url : cp + "/rest/cache/remove",
				jsonp : "callback",
				dataType : "jsonp",
				data : {
					key : key,
					cacheHost : cacheHost,
					cachePort : cachePort,
					cacheName : cacheName
				},
				success : function(response) {
					//print(JSON.stringify(response.result, null, ' '));
					values();
				}
			});//eof ajax
		};
	});//eof dom ready!
</script>
</head>
<body>

	<h2>JDG Client</h2>
	<hr>
	<label>Host:</label>
	<input id="cacheHost" type="text" size="15"
		value='<%=request.getServletContext().getInitParameter("jdg_server") == null ? "127.0.0.1"
					: request.getServletContext().getInitParameter("jdg_server")%>' />
	<label>Port:</label>
	<input id="cachePort" type="text" size="5"
		value='<%=request.getServletContext().getInitParameter("jdg_server") == null ? "11222"
					: request.getServletContext().getInitParameter("jdg_port")%>' />
	<label>Cache:</label>
	<input id="cacheName" type="text" size="30"
		value='<%=request.getServletContext().getInitParameter("jdg_server") == null ? "httpSessionCache"
					: request.getServletContext().getInitParameter("jdg_cache")%>' />
	<input id="btnStats" type="button" value="Cache Stats"
		onclick="stats();" />
	<input id="btnValues" type="button" value="Cache Values"
		onclick="values();" />
	<hr>
	<label>Cache Key/Value:</label>
	<input id="attrKey" type="text" size="20" title="Key" />
	<input id="attrValue" type="text" size="20" title="Value" />
	<input id="btnSave" type="button" value="put"
		onclick="save();" />
	<input id="btnRemove" type="button" value="remove"
		onclick="remove();" />
	<hr>
	<br />Output
	<br />
	<textarea wrap="on" id="result" cols="120" rows="30"></textarea>
	<br />
</body>
</html>
