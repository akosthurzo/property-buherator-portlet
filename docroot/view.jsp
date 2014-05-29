<%
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.liferay.portal.kernel.dao.search.SearchContainer" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="java.util.Properties" %>
<%@ page import="com.liferay.portal.kernel.util.ListUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Validator" %>
<%@ page import="javax.portlet.PortletPreferences" %>
<%@ page import="com.liferay.portal.kernel.util.PrefsPropsUtil" %>
<%@ page import="com.liferay.portal.kernel.util.StringPool" %>
<%@ page import="com.liferay.portal.kernel.dao.search.ResultRow" %>
<%@ page import="com.liferay.portal.kernel.util.HtmlUtil" %>
<%@ page import="com.liferay.portal.kernel.util.StringUtil" %>
<%@ page import="com.liferay.portal.kernel.util.StringBundler" %>
<%@ page import="com.liferay.portal.kernel.language.LanguageUtil" %>
<%@ page import="com.liferay.portal.util.PortalUtil" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>

<portlet:defineObjects />
<liferay-theme:defineObjects />

<%
	List<String> headerNames = new ArrayList<String>();

	headerNames.add("property");
	headerNames.add("value");
	headerNames.add("source");

	String emptyResultsMessage = "no-portal-properties-were-found-that-matched-the-keywords";

	SearchContainer searchContainer = new SearchContainer(renderRequest, null, null, SearchContainer.DEFAULT_CUR_PARAM, SearchContainer.DEFAULT_DELTA, renderResponse.createRenderURL(), headerNames, emptyResultsMessage);

	Map<String, String> filteredProperties = new TreeMap<String, String>();

	Properties properties = null;

	properties = PortalUtil.getPortalProperties();

	String keywords = null;

	for (Map.Entry<Object, Object> entry : properties.entrySet()) {
		String property = (String)entry.getKey();
		String value = (String)entry.getValue();

		if (Validator.isNull(keywords) || property.contains(keywords) || value.contains(keywords)) {
			filteredProperties.put(property, value);
		}
	}

	for (Map.Entry<Object, Object> entry : properties.entrySet()) {
		String property = (String)entry.getKey();
		String value = (String)entry.getValue();
	}

	List results = ListUtil.fromCollection(filteredProperties.entrySet());

	searchContainer.setTotal(results.size());

	results = ListUtil.subList(results, searchContainer.getStart(), searchContainer.getEnd());

	searchContainer.setResults(results);

	List resultRows = searchContainer.getResultRows();

	PortletPreferences serverPortletPreferences = PrefsPropsUtil.getPreferences();

	Map<String, String[]> serverPortletPreferencesMap = serverPortletPreferences.getMap();

	PortletPreferences companyPortletPreferences = PrefsPropsUtil.getPreferences(themeDisplay.getCompanyId());

	Map<String, String[]> companyPortletPreferencesMap = companyPortletPreferences.getMap();

	for (int i = 0; i < results.size(); i++) {
		Map.Entry entry = (Map.Entry) results.get(i);

		String property = (String) entry.getKey();
		String value = (String) entry.getValue();

		boolean overriddenPropertyValue = false;

		if (serverPortletPreferencesMap.containsKey(property)) {
			value = serverPortletPreferences.getValue(property, StringPool.BLANK);

			overriddenPropertyValue = true;
		}

		if (companyPortletPreferencesMap.containsKey(property)) {
			value = companyPortletPreferences.getValue(property, StringPool.BLANK);

			overriddenPropertyValue = true;
		}

		ResultRow row = new ResultRow(entry, property, i);

		// Property

		row.addText(HtmlUtil.escape(StringUtil.shorten(property, 80)));

		// Value

		if (Validator.isNotNull(value)) {
			if (value.length() > 80) {
				StringBundler sb = new StringBundler(5);

				sb.append("<span onmouseover=\"Liferay.Portal.ToolTip.show(this, '");
				sb.append(HtmlUtil.escape(value));
				sb.append("')\">");
				sb.append(HtmlUtil.escape(StringUtil.shorten(value, 80)));
				sb.append("</span>");

				row.addText(sb.toString());
			} else {
				row.addText(HtmlUtil.escape(StringUtil.shorten(value, 80)));
			}
		} else {
			row.addText(StringPool.BLANK);
		}

		// Source

		StringBundler sb = new StringBundler(5);

		sb.append("<span onmouseover=\"Liferay.Portal.ToolTip.show(this, '");

		if (overriddenPropertyValue) {
			sb.append(LanguageUtil.get(pageContext, "the-value-of-this-property-was-overridden-using-the-control-panel-and-is-stored-in-the-database"));
		} else {
			sb.append(LanguageUtil.get(pageContext, "the-value-of-this-property-is-read-from-a-portal.properties-file-or-one-of-its-extension-files"));
		}

		sb.append("')\"><img alt=\"");

		if (overriddenPropertyValue) {
			sb.append(LanguageUtil.get(pageContext, "the-value-of-this-property-was-overridden-using-the-control-panel-and-is-stored-in-the-database"));
		} else {
			sb.append(LanguageUtil.get(pageContext, "the-value-of-this-property-is-read-from-a-portal.properties-file-or-one-of-its-extension-files"));
		}

		sb.append("\" src=\"");
		sb.append(themeDisplay.getPathThemeImages());

		if (overriddenPropertyValue) {
			sb.append("/common/saved_in_database.png");
		} else {
			sb.append("/common/page.png");
		}

		sb.append("\" /></span>");

		row.addText(sb.toString());


		// Add result row

		resultRows.add(row);
	}
%>

<liferay-ui:search-iterator searchContainer="<%= searchContainer %>" />
