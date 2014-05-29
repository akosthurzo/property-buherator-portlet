package com.liferay.portlet.buher.action;

import com.liferay.portal.model.Portlet;
import com.liferay.portal.security.permission.PermissionChecker;
import com.liferay.portlet.BaseControlPanelEntry;


/**
 * Control panel entry class EditPropertyActionControlPanelEntry
 */
public class EditPropertyActionControlPanelEntry extends BaseControlPanelEntry {

    /**
     * Default constructor. 
     */
    public EditPropertyActionControlPanelEntry() {
    }

    @Override
    public boolean isVisible(PermissionChecker permissionChecker, Portlet portlet)
            throws Exception {
        return false;
    }

}