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

import java.io.IOException;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import javax.json.Json;
import javax.json.JsonArrayBuilder;
import javax.json.JsonObjectBuilder;
import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.PasswordCallback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.sasl.RealmCallback;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;

import org.infinispan.client.hotrod.RemoteCache;
import org.infinispan.client.hotrod.RemoteCacheManager;
import org.infinispan.client.hotrod.Search;
import org.infinispan.client.hotrod.configuration.ConfigurationBuilder;
import org.infinispan.commons.util.CloseableIterator;
import org.infinispan.query.dsl.QueryFactory;

import com.redhat.jdg.demo.util.BeanUtil;


@Path("/cache")
public class JdgInfoService {

	//private static final Logger log = Logger.getLogger(JdgInfoService.class.getName());
	private static final String REALM = "ApplicationRealm";
	
	@GET
	@POST
	@Path("/stats")
	@Produces({ "application/javascript" })
	public String getCacheStats(@QueryParam(value="cacheHost") String cacheHost,@QueryParam(value="cachePort")String cachePort,@QueryParam(value="cacheName")String cacheName,@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    JsonArrayBuilder jsonArray = Json.createArrayBuilder();
	    RemoteCacheManager rcm = null;
	    try {
		    rcm = remoteCacheManager(cacheHost, cachePort, null, null);
		    RemoteCache<Object, Object> cache = rcm.getCache(cacheName);
		    jsonArray.add(Json.createObjectBuilder().add("name", cache.getName() ));
		    jsonArray.add(Json.createObjectBuilder().add("size", cache.size() ));
		    for (Entry<String, String> entry : cache.stats().getStatsMap().entrySet()){
		    	jsonArray.add(Json.createObjectBuilder().add(entry.getKey() , entry.getValue()));
			}
		    builder.add("result", jsonArray);
		    rcm.stop();
	    }catch(Exception ex) {
	    	if(rcm != null) rcm.stop();
	    	builder.add("result", ex.getMessage());
	    } 
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}

	@GET
	@POST
	@Path("/values")
	@Produces({ "application/javascript" })
	public String getCacheValues(@QueryParam(value="cacheHost") String cacheHost,@QueryParam(value="cachePort")String cachePort,@QueryParam(value="cacheName")String cacheName,@QueryParam("callback") String callback) {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    JsonArrayBuilder jsonArray = Json.createArrayBuilder();
	    RemoteCacheManager rcm = null;
	    try {
		    rcm = remoteCacheManager(cacheHost, cachePort, null, null);
		    RemoteCache<Object, Object> cache = rcm.getCache(cacheName);
		    jsonArray.add(Json.createObjectBuilder().add("name", cache.getName() ));
		    jsonArray.add(Json.createObjectBuilder().add("size", cache.size() ));
		    Set<Object> keySet = cache.keySet();
		    for(Object key:keySet) {
		    	if(key != null) {
		    		Object value = cache.get(key);
		    		if(key != null && value != null) {
		    			jsonArray.add(Json.createObjectBuilder().add(key.toString() , value.getClass().isPrimitive() || value instanceof String ? value.toString(): BeanUtil.deepToString(value)));	
		    		}
		    		
		    	}
		    }
 		    
		    rcm.stop();
	    }catch(Exception ex) {
	    	if(rcm != null) rcm.stop();
	    	builder.add("result", ex.getMessage());
	    } 
	    builder.add("result", jsonArray);
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}
	
	
	
	@GET
	@POST
	@Path("/save")
	@Produces({ "application/javascript" })
	public String save(@QueryParam(value="key") String key,@QueryParam(value="value")String value,@QueryParam(value="cacheHost") String cacheHost,@QueryParam(value="cachePort")String cachePort,@QueryParam(value="cacheName")String cacheName,@QueryParam("callback") String callback)  {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    JsonArrayBuilder jsonArray = Json.createArrayBuilder();
	    RemoteCacheManager rcm = null;
	    try {
		    rcm = remoteCacheManager(cacheHost, cachePort, null, null);
		    RemoteCache<Object, Object> cache = rcm.getCache(cacheName);
		    jsonArray.add(Json.createObjectBuilder().add("before_put", cache.size() ));
		    cache.put(key, value);
		    jsonArray.add(Json.createObjectBuilder().add("after_put", cache.size() ));
		    rcm.stop();
	    }catch(Exception ex) {
	    	if(rcm != null) rcm.stop();
	    	builder.add("result", ex.getMessage());
	    } 
	    builder.add("result", jsonArray);
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}
	
	
	@GET
	@POST
	@Path("/remove")
	@Produces({ "application/javascript" })
	public String remove(@QueryParam(value="key") String key,@QueryParam(value="cacheHost") String cacheHost,@QueryParam(value="cachePort")String cachePort,@QueryParam(value="cacheName")String cacheName,@QueryParam("callback") String callback)  {
		//Convert object to JSON
	    JsonObjectBuilder builder = Json.createObjectBuilder();
	    JsonArrayBuilder jsonArray = Json.createArrayBuilder();
	    RemoteCacheManager rcm = null;
	    try {
		    rcm = remoteCacheManager(cacheHost, cachePort, null, null);
		    RemoteCache<Object, Object> cache = rcm.getCache(cacheName);
		    jsonArray.add(Json.createObjectBuilder().add("before_remove", cache.size() ));
		    cache.remove(key);
		    jsonArray.add(Json.createObjectBuilder().add("after_remove", cache.size() ));
		    rcm.stop();
	    }catch(Exception ex) {
	    	if(rcm != null) rcm.stop();
	    	builder.add("result", ex.getMessage());
	    } 
	    builder.add("result", jsonArray);
	    //return as callback javascript padding
	    return (callback + "(" + builder.build().toString() + ")");
	}
	
	private static RemoteCacheManager remoteCacheManager(String serverName,String port,String userName,String password) {
		    RemoteCacheManager cacheManager;
			ConfigurationBuilder confBuilder = new org.infinispan.client.hotrod.configuration.ConfigurationBuilder()
					.tcpNoDelay(true).connectionPool().numTestsPerEvictionRun(3).testOnBorrow(true).testOnReturn(true)
					.testWhileIdle(true).addServers(serverName+":"+port);
			org.infinispan.client.hotrod.configuration.Configuration remoteConf = null;
			if (userName != null && password != null) {
				remoteConf = confBuilder
						// add configuration for authentication
						.security().authentication().serverName(serverName) // define
																				// server
																				// name,
																				// should
																				// be
																				// specified
																				// in
																				// XML
																				// configuration
						.saslMechanism("DIGEST-MD5") // define SASL mechanism,
														// in this example we
														// use DIGEST with MD5
														// hash
						.callbackHandler(new CallbackHandler() {

							@Override
							public void handle(Callback[] callbacks) throws IOException, UnsupportedCallbackException {
								for (Callback callback : callbacks) {
									if (callback instanceof NameCallback) {
										((NameCallback) callback).setName(userName);
									} else if (callback instanceof PasswordCallback) {
										((PasswordCallback) callback).setPassword(password.toCharArray());
									} else if (callback instanceof RealmCallback) {
										((RealmCallback) callback).setText(REALM);
									} else {
										throw new UnsupportedCallbackException(callback);
									}
								}
							}
						}) // define login handler, implementation defined
						.enable().build();
			} else {
				remoteConf = confBuilder.build();
			}
			cacheManager = new RemoteCacheManager(remoteConf);
		return cacheManager;
	}
	
	
	 
	
}
