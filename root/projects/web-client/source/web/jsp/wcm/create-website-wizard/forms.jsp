<%--
  Copyright (C) 2005 Alfresco, Inc.
 
  Licensed under the Mozilla Public License version 1.1 
  with a permitted attribution clause. You may obtain a
  copy of the License at
 
    http://www.alfresco.org/legal/license.txt
 
  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
  either express or implied. See the License for the specific
  language governing permissions and limitations under the
  License.
--%>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="/WEB-INF/alfresco.tld" prefix="a" %>
<%@ taglib uri="/WEB-INF/repo.tld" prefix="r" %>

<%@ page buffer="32kb" contentType="text/html;charset=UTF-8" %>
<%@ page isELIgnored="false" %>

<h:panelGrid columns="1" cellpadding="2" cellpadding="2" width="100%">
   <%-- Form selection list - scrollable DIV area --%>
   <h:outputText styleClass="mainSubText" value="#{msg.website_select_form}:" />
   <h:panelGroup>
      <f:verbatim><div style="height:144px;*height:148px;width:100%;overflow:auto" class='selectListTable'></f:verbatim>
      <a:selectList id="form-list" activeSelect="true" style="width:100%" itemStyleClass="selectListItem">
         <a:listItems value="#{WizardManager.bean.formsList}" />
         <h:commandButton value="#{msg.add_to_list_button}" styleClass="dialogControls" actionListener="#{WizardManager.bean.addForm}" />
      </a:selectList>
      <f:verbatim></div></f:verbatim>
   </h:panelGroup>
   <h:commandButton value="#{msg.create_form}" style="margin:2px" styleClass="dialogControls" action="wizard:createForm" />
   
   <%-- Selected Form table, with configuration buttons and info text --%>
   <f:verbatim><div style='padding:4px'></div></f:verbatim>
   <h:dataTable value="#{WizardManager.bean.formsDataModel}" var="row" 
                rowClasses="selectedItemsRow,selectedItemsRowAlt"
                styleClass="selectedItems" headerClass="selectedItemsHeader"
                cellspacing="0" cellpadding="4" width="100%"
                rendered="#{WizardManager.bean.formsDataModel.rowCount != 0}">
      <h:column>
         <f:facet name="header">
            <h:outputText value="#{msg.website_selected_forms}" />
         </f:facet>
         <f:verbatim>
            <img style="float:left" src="<%=request.getContextPath()%>/images/icons/webform_large.gif" />
         </f:verbatim>
         <h:panelGrid columns="2" cellspacing="1">
            <h:outputText value="#{msg.name}: " />
            <h:outputText value="#{row.title}" />
            
            <h:outputText value="#{msg.description}: " />
            <h:outputText style="font-style:italic" rendered="#{empty row.description}" value="#{msg.description_not_set}" />
            <h:outputText rendered="#{!empty row.description}" value="#{row.description}" />
            
            <h:outputText value="#{msg.workflow}: " />
            <h:outputText rendered="#{row.workflow != null}" value="#{row.workflow.title}" />
            <h:panelGroup rendered="#{row.workflow == null}">
               <h:outputText value="#{msg.workflow_not_set}" />
               <h:graphicImage url="/images/icons/warning.gif" style="padding:2px" width="16" height="16"
                  rendered="#{row.workflow != null && row.workflow.params == null}" title="#{msg.workflow_not_configured}" />
            </h:panelGroup>
            
            <h:outputText value="#{msg.output_path_pattern}: " />
            <h:outputText value="#{row.outputPathPattern}" />
            
            <h:outputText value="#{msg.rendering_engines_selected}: " />
            <h:outputText rendered="#{row.templates == null}" value="0" />
            <h:outputText rendered="#{row.templates != null}" value="#{row.templatesSize}" />
         </h:panelGrid>
      </h:column>
      <h:column>
         <f:facet name="header">
            <h:outputText value="#{msg.actions}" />
         </f:facet>
         <h:panelGrid columns="1" cellspacing="2" rendered="#{WizardManager.bean.editMode == false}">
            <h:commandButton id="cmd1-1" value="#{msg.form_template_details}" styleClass="dialogControls" action="dialog:formTemplateDetails" actionListener="#{WizardManager.bean.setupFormAction}" />
            <h:commandButton id="cmd1-2" value="#{msg.form_template_conf_workflow}" styleClass="dialogControls" action="dialog:formTemplateWorkflow" actionListener="#{WizardManager.bean.setupFormAction}" disabled="#{row.workflow == null}" />
            <h:commandButton id="cmd1-3" value="#{msg.form_template_select_templates}" styleClass="dialogControls" action="dialog:formTemplateTemplates" actionListener="#{WizardManager.bean.setupFormAction}" />
         </h:panelGrid>
         <h:panelGrid columns="1" cellspacing="2" rendered="#{WizardManager.bean.editMode == true}">
            <h:commandButton id="cmd2-1" value="#{msg.form_template_details}" styleClass="dialogControls" action="dialog:editFormTemplateDetails" actionListener="#{WizardManager.bean.setupFormAction}" />
            <h:commandButton id="cmd2-2" value="#{msg.form_template_conf_workflow}" styleClass="dialogControls" action="dialog:editFormTemplateWorkflow" actionListener="#{WizardManager.bean.setupFormAction}" disabled="#{row.workflow == null}" />
            <h:commandButton id="cmd2-3" value="#{msg.form_template_select_templates}" styleClass="dialogControls" action="dialog:editFormTemplateTemplates" actionListener="#{WizardManager.bean.setupFormAction}" />
         </h:panelGrid>
      </h:column>
      <h:column>
         <a:actionLink actionListener="#{WizardManager.bean.removeForm}" image="/images/icons/delete.gif"
                       value="#{msg.remove}" showLink="false" style="padding:4px" />
      </h:column>
   </h:dataTable>
   
   <a:panel id="no-items" rendered="#{WizardManager.bean.formsDataModel.rowCount == 0}">
      <h:panelGrid width="100%" columns="1" cellpadding="2"
            styleClass="selectedItems" rowClasses="selectedItemsHeader,selectedItemsRow">
         <h:outputText id="no-items-name" value="#{msg.name}" />
         <h:outputText styleClass="selectedItemsRow" id="no-items-msg" value="#{msg.no_selected_items}" />
      </h:panelGrid>
   </a:panel>
</h:panelGrid>
