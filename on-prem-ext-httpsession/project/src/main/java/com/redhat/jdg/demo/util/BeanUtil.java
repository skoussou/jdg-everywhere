package com.redhat.jdg.demo.util;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

/**
 *  BeanUtil class includes some  useful methods for beans objects.
 *
  *
 */
public class BeanUtil {

	/**
	 * Represents a single bean propery of a bean
	 *
	 */
	public static class BeanProperty {
		private Class<?> propertyClass;

		private Object propertyValue;

		private String propertyName;

		private Method readMethod;

		private Method writeMethod;

		public Class<?> getPropertyClass() {
			return propertyClass;
		}

		public void setPropertyClass(Class<?> propertyClass) {
			this.propertyClass = propertyClass;
		}

		public String getPropertyName() {
			return propertyName;
		}

		public void setPropertyName(String propertyName) {
			this.propertyName = propertyName;
		}

		public Object getPropertyValue() {
			return propertyValue;
		}

		public void setPropertyValue(Object propertyValue) {
			this.propertyValue = propertyValue;
		}

		public Method getReadMethod() {
			return readMethod;
		}

		public void setReadMethod(Method readMethod) {
			this.readMethod = readMethod;
		}

		public Method getWriteMethod() {
			return writeMethod;
		}

		public void setWriteMethod(Method writeMethod) {
			this.writeMethod = writeMethod;
		}

	}

	/**
	 * Gives bean properties as array
	 *
	 * @param bean
	 * @return PropertyDescriptor[]
	 */
	public static PropertyDescriptor[] getBeanProperties(Object bean) {
		if (bean == null)
			return null;
		BeanInfo bi;
		try {
			bi = Introspector.getBeanInfo(bean.getClass(),
					Introspector.USE_ALL_BEANINFO);
		} catch (IntrospectionException e) {
			// ADFSystemLog.getLog().error("An error occured while inspecting
			// class "+bean.getClass(),e);
			return null;
		}
		return bi.getPropertyDescriptors();
	}

	/**
	 * Gives bean properties as map
	 *
	 * @param bean
	 * @return Map<String, BeanProperty>
	 */
	public static Map<String, BeanProperty> getBeanPropertyMap(Object bean) {
		Map<String, BeanProperty> pMap = new HashMap<String, BeanProperty>();
		if (bean == null)
			return pMap;
		PropertyDescriptor[] properties = getBeanProperties(bean);
		if (properties == null)
			return pMap;
		for (int i = 0; i < properties.length; i++) {
			BeanProperty property = new BeanProperty();
			property.setPropertyClass(properties[i].getPropertyType());
			property.setPropertyName(properties[i].getName());
			property.setReadMethod(properties[i].getReadMethod());
			property.setWriteMethod(properties[i].getWriteMethod());
			try {
				property.setPropertyValue(properties[i].getReadMethod().invoke(
						bean, new Object[] {}));
				pMap.put(property.getPropertyName(), property);
			} catch (Exception e) {
				// ADFSystemLog.getLog().error(e);
			}
		}
		return pMap;
	}

	/**
	 * Gives property of a bean
	 *
	 * @param bean
	 * @param propertyName
	 * @return BeanProperty
	 */
	public static BeanProperty getBeanProperty(Object bean, String propertyName) {
		if (bean == null || propertyName == null
				|| propertyName.trim().length() == 0)
			return null;
		PropertyDescriptor[] properties = getBeanProperties(bean);
		if (properties == null)
			return null;
		for (int i = 0; i < properties.length; i++) {
			if (properties[i].getName().equals(propertyName)) {
				BeanProperty property = new BeanProperty();
				property.setPropertyClass(properties[i].getPropertyType());
				property.setPropertyName(properties[i].getName());
				property.setReadMethod(properties[i].getReadMethod());
				property.setWriteMethod(properties[i].getWriteMethod());
				try {
					property.setPropertyValue(properties[i].getReadMethod()
							.invoke(bean, new Object[] {}));
				} catch (Exception e) {
					// ADFSystemLog.getLog().error(e);
					return null;
				}
				return property;
			}

		}
		return null;
	}

	/**
	 * Gives property of a bean
	 *
	 * @param bean
	 * @param propertyName
	 * @return PropertyDescriptor
	 */
	public static PropertyDescriptor getBeanPropertyDescription(Object bean,
			String propertyName) {
		if (bean == null || propertyName == null
				|| propertyName.trim().length() == 0)
			return null;
		PropertyDescriptor[] properties = getBeanProperties(bean);
		if (properties == null)
			return null;
		for (int i = 0; i < properties.length; i++) {
			if (properties[i].getName().equals(propertyName)) {

				return properties[i];
			}

		}
		return null;
	}

	/**
	 * Compares two beans and returns changed members.This method just checks
	 * comparable & primitive members of the bean
	 *
	 * @param prevBean
	 * @param currentBean
	 * @return Changed parameters map
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public static Map<String, BeanProperty> getChangedProperties(
			Object prevBean, Object currentBean) {
		Map<String, BeanUtil.BeanProperty> prevMap = BeanUtil
				.getBeanPropertyMap(prevBean);
		Map<String, BeanUtil.BeanProperty> currMap = BeanUtil
				.getBeanPropertyMap(currentBean);
		Map<String, BeanUtil.BeanProperty> changeMap = new HashMap<String, BeanUtil.BeanProperty>();
		for (String fieldName : currMap.keySet()) {
			if (!prevMap.keySet().contains(fieldName)
					|| !prevBean.getClass().equals(currentBean.getClass())) {
				changeMap.put(fieldName, currMap.get(fieldName));
				continue;
			}
			Object prevVal = prevMap.get(fieldName).getPropertyValue();
			Object currVal = currMap.get(fieldName).getPropertyValue();
			if (prevVal == null && currVal == null)
				continue;
			if ((prevVal == null && currVal != null)
					|| (currVal == null && prevVal != null)) {
				changeMap.put(fieldName, currMap.get(fieldName));
				continue;
			}
			if (prevVal instanceof Comparable
					&& ((Comparable) prevVal).compareTo(currVal) != 0) {
				changeMap.put(fieldName, currMap.get(fieldName));
				continue;
			}
			if (prevVal.getClass().isPrimitive() && prevVal != currVal) {
				changeMap.put(fieldName, currMap.get(fieldName));
				continue;
			}
			if (prevVal.getClass().isEnum() && prevVal != currVal) {
				changeMap.put(fieldName, currMap.get(fieldName));
				continue;
			}

		}
		return changeMap;
	}

	/**
	 * Copies members of the soruce bean to target target bean.
	 * The target bean must be assignable from the source bean.
	 *
	 * @param src
	 * @param target
	 */
	public static void copyBean(Object src, Object target) {
		if (src == null) {
			throw new NullPointerException("src is null");
		}
		if (target == null) {
			throw new NullPointerException("target is null");
		}
		if (target.getClass().isAssignableFrom(src.getClass())
				|| src.getClass().isAssignableFrom(target.getClass())) {
			Map<String, BeanUtil.BeanProperty> srcMap = BeanUtil
					.getBeanPropertyMap(src);
			Map<String, BeanUtil.BeanProperty> targetMap = BeanUtil
					.getBeanPropertyMap(target);
			for (String propName : srcMap.keySet()) {
				if (targetMap.containsKey(propName)) {
					BeanProperty srcProp = srcMap.get(propName);
					BeanProperty targetProp = targetMap.get(propName);
					if (targetProp.getWriteMethod() != null){
					try {
						targetProp.getWriteMethod().invoke(target,
								srcProp.getPropertyValue());
					} catch (Exception e) {

					}
					}

				}
			}
		}
	}

  /**
 * Converts bean & it's parameters to string .
 * @param bean
 * @return string representation of the bean and its properties
 */
public static String deepToString(Object bean ){
  return deepToString(bean,0);
}


private static String deepToString(Object bean,int level ){
  StringBuilder sb = new StringBuilder();
  sb.append("Class ->"+bean.getClass()+"  toString()->:"+bean.toString()+" \n");
  Map<String,BeanUtil.BeanProperty> map =  getBeanPropertyMap(bean);
    for ( String propName : map.keySet()) {
       if (propName.equals("class") || propName.equals("bytes")) continue;
     BeanUtil.BeanProperty prop = map.get(propName);
     for (int i = 0 ; i < level;i++){
       sb.append("-");
     }
     if (prop.getPropertyValue() == null) {
       sb.append("Property "+propName+" : null \n");
     }else{
       sb.append("Property "+propName+" :"+deepToString(prop.getPropertyValue(),level+1)+"\n");
     }
  }

  return sb.toString();
}
}
