/*
 * JBoss, Home of Professional Open Source
 * Copyright 2016 Red Hat Inc. and/or its affiliates and other
 * contributors as indicated by the @author tags. All rights reserved.
 * See the copyright.txt in the distribution for a full listing of
 * individual contributors.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */
package com.redhat.jdg.demo.service;

import java.util.Enumeration;

import javax.json.Json;
import javax.json.JsonArrayBuilder;
import javax.json.JsonObjectBuilder;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;

/**
 * A simple REST http session service
 *
 * @author serhat@redhat.com
 *
 */

@Path("/session")
public class SessionService {

	@Context
	HttpServletRequest httpReq;


	@GET
	@POST
	@Path("/sessionId")
	@Produces({ "application/javascript" })
	public String getSessionId(@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    builder.add("result", httpReq.getRequestedSessionId());
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}

	@GET
	@POST
	@Path("/userName")
	@Produces({ "application/javascript" })
	public String getUserName(@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    builder.add("result",  httpReq.getRemoteUser() != null ? httpReq.getRemoteUser() : "null");
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}

	@GET
	@POST
	@Path("/serverName")
	@Produces({ "application/javascript" })
	public String getServerName(@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    builder.add("result", httpReq.getServerName());
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}


	@GET
	@POST
	@Path("/serverAddress")
	@Produces({ "application/javascript" })
	public String getServerAddress(@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    builder.add("result", httpReq.getLocalAddr());
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}

	@GET
	@POST
	@Path("/requestHeaders")
	@Produces({ "application/javascript" })
	public String getRequestHeaders(@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    JsonArrayBuilder jsonArray = Json.createArrayBuilder();
		Enumeration<String> headerNames = httpReq.getHeaderNames();
		while(headerNames.hasMoreElements()){
			String headerName = headerNames.nextElement();
			jsonArray.add(Json.createObjectBuilder().add(headerName, httpReq.getHeader(headerName)));
		}

	    builder.add("result", jsonArray);
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");

	}

	@GET
	@POST
	@Path("/sessionAttributes")
	@Produces({ "application/javascript" })
	public String getSessionAttributes(@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    JsonArrayBuilder jsonArray = Json.createArrayBuilder();
	    Enumeration<String> attributeNames=  httpReq.getSession().getAttributeNames();
	    while(attributeNames.hasMoreElements()){
	    	String attributeName = attributeNames.nextElement();
	    	Object val = httpReq.getSession(true).getAttribute(attributeName);
	    	jsonArray.add(Json.createObjectBuilder().add(attributeName, val == null ? "NULL" :val.toString()));
	    }
	    builder.add("result", jsonArray);
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}

	@GET
	@POST
	@Path("/sessionInfo")
	@Produces({ "application/javascript" })
	public String getSessionInfo(@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    JsonArrayBuilder jsonArray = Json.createArrayBuilder();
		jsonArray.add(Json.createObjectBuilder().add("serverName", httpReq.getServerName()));
		jsonArray.add(Json.createObjectBuilder().add("serverAddress", httpReq.getLocalAddr()));
		jsonArray.add(Json.createObjectBuilder().add("serverPort", httpReq.getLocalPort()));
		jsonArray.add(Json.createObjectBuilder().add("sessionId", httpReq.getSession().getId()));
		jsonArray.add(Json.createObjectBuilder().add("userName", httpReq.getRemoteUser() != null ? httpReq.getRemoteUser() : "null"));


		JsonArrayBuilder attributeArr = Json.createArrayBuilder();
		Enumeration<String> attributeNames=  httpReq.getSession().getAttributeNames();
	    while(attributeNames.hasMoreElements()){
	    	String attributeName = attributeNames.nextElement();
	    	Object val = httpReq.getSession(true).getAttribute(attributeName);
	    	attributeArr.add(Json.createObjectBuilder().add(attributeName, val == null ? "NULL": val.toString()));
	    }

		jsonArray.add(Json.createObjectBuilder().add("SessionAttributes", attributeArr));

		JsonArrayBuilder headerArr = Json.createArrayBuilder();
		Enumeration<String> headerNames = httpReq.getHeaderNames();
		while(headerNames.hasMoreElements()){
			String headerName = headerNames.nextElement();
			headerArr.add(Json.createObjectBuilder().add(headerName, httpReq.getHeader(headerName)));
		}
		jsonArray.add(Json.createObjectBuilder().add("headers", headerArr));
	    builder.add("result", jsonArray);
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}

	@GET
	@POST
	@Path("/setAttribute")
	@Produces({ "application/javascript" })
	public String addSessionAttribute(@QueryParam(value="key") String key,@QueryParam(value="value")String value,@QueryParam("callback") String callback)  {
		httpReq.getSession().setAttribute(key, value);
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    Object val = httpReq.getSession(true).getAttribute(key);
	    builder.add("result", val == null ? "NULL": val.toString());
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}


	@GET
	@POST
	@Path("/removeAttribute")
	@Produces({ "application/javascript" })
	public String removeSessionAttribute(@QueryParam(value="key") String key,@QueryParam("callback") String callback)  {
		httpReq.getSession().removeAttribute(key);
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    builder.add("result", "ok");
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}
}
