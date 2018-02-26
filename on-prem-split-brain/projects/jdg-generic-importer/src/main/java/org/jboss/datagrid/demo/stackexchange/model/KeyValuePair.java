package org.jboss.datagrid.demo.stackexchange.model;

import java.io.Serializable;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name="row")
@XmlAccessorType(XmlAccessType.FIELD)
public class KeyValuePair implements Serializable {
	
    @XmlAttribute(name = "Id")
    String id;

    @XmlAttribute(name = "Value")
    String value;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		value = value;
	}

    @Override
    public String toString() {
        return String.format("KeyPair id: %s, Value: %s",this.id,this.value);
    }
	
}


