/*
 * Copyright (C) 2005-2008 Alfresco Software Limited.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

 * As a special exception to the terms and conditions of version 2.0 of 
 * the GPL, you may redistribute this Program in connection with Free/Libre 
 * and Open Source Software ("FLOSS") applications as described in Alfresco's 
 * FLOSS exception.  You should have recieved a copy of the text describing 
 * the FLOSS exception, and it is also available here: 
 * http://www.alfresco.com/legal/licensing"
 */
package org.alfresco.web.framework;

import java.util.HashMap;
import java.util.Map;

import org.alfresco.config.Config;
import org.alfresco.config.ConfigService;
import org.alfresco.web.config.WebFrameworkConfigElement;
import org.alfresco.web.config.WebFrameworkConfigElement.TypeDescriptor;
import org.alfresco.web.framework.exception.WebFrameworkServiceException;
import org.alfresco.web.scripts.RemoteStore;
import org.alfresco.web.scripts.SearchPath;
import org.alfresco.web.scripts.Store;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

/**
 * The Class WebFrameworkService.
 * 
 * @author muzquiano
 */
public class WebFrameworkService
    implements ApplicationContextAware
{
    private static final Log logger = LogFactory.getLog(WebFrameworkService.class);
        
    /** The application context. */
    private ApplicationContext applicationContext;
    
    /** The config service. */
    private ConfigService configService;
    
    /** The web framework config. */
    private WebFrameworkConfigElement webFrameworkConfig;
    
    /** A map of type ids to MultiModelObjectPersister implementations. */
    private Map<String, ModelObjectPersister> typeIdToMultiPersisterMap;
    
    /** A map of type ids to default Persister implementations. */
    private Map<String, ModelObjectPersister> typeIdToDefaultPersisterMap;

    /** A map of persister ids to Persister implementations. */
    private Map<String, ModelObjectPersister> persisterIdToPersisterMap;
    
    /* (non-Javadoc)
     * @see org.springframework.context.ApplicationContextAware#setApplicationContext(org.springframework.context.ApplicationContext)
     */
    public void setApplicationContext(ApplicationContext applicationContext)
        throws BeansException
    {
        this.applicationContext = applicationContext;
    }
    
    /**
     * Gets the application context.
     * 
     * @return the application context
     */
    public ApplicationContext getApplicationContext()
    {
        return this.applicationContext;
    }
    
    /**
     * Sets the config service.
     * 
     * @param configService the new config service
     */
    public void setConfigService(ConfigService configService)
    {
        this.configService = configService;
    }
    
    /**
     * Gets the config service.
     * 
     * @return the config service
     */
    public ConfigService getConfigService()
    {
        return this.configService;
    }     
    
    /**
     * Gets the web framework config.
     * 
     * @return the web framework config
     */
    public WebFrameworkConfigElement getWebFrameworkConfig()
    {
        return this.webFrameworkConfig;
    }

    /**
     * Inits the bean.
     */
    protected void init()
    {
        Config config = getConfigService().getConfig("WebFramework");
        this.webFrameworkConfig = (WebFrameworkConfigElement)config.getConfigElement("web-framework");
        
        initPersisters();
    }

    /**
     * Returns an object manager instance which has no bindings to
     * persister context.
     * 
     * @return object manager
     */
    public ModelObjectManager getObjectManager()
        throws WebFrameworkServiceException
    {
        return getObjectManager(new ModelPersistenceContext());
    }
    
    /**
     * Returns an object manager instance which has been bound to the
     * provided persister context.
     * 
     * @param context the context
     * 
     * @return object manager
     */
    public ModelObjectManager getObjectManager(ModelPersistenceContext context)
        throws WebFrameworkServiceException
    {
        ModelObjectManager modelObjectManager = null;
        try
        {
            modelObjectManager = ModelObjectManager.newInstance(this, context);
        }
        catch (Exception ex)
        {
            throw new WebFrameworkServiceException("Exception while instantiating model object manager", ex);
        }
        return modelObjectManager;
    }
    
    /**
     * Returns an object service instance which will be bound to the
     * provided user and repository store ids.
     * 
     * @param userId the user id
     * @param repositoryStoreId the repository store id
     * 
     * @return the object service
     */
    public ModelObjectManager getObjectService(String userId, String repositoryStoreId)
        throws WebFrameworkServiceException
    {
        ModelPersistenceContext context = new ModelPersistenceContext(userId);
        context.putValue(ModelPersistenceContext.REPO_STOREID, repositoryStoreId);
        
        return getObjectManager(context);        
    }
    
    /**
     * Returns the default persister for a given object type id
     * 
     * @param objectTypeId
     * @return
     */
    public ModelObjectPersister getDefaultPersister(String objectTypeId)
    {
        return (ModelObjectPersister) typeIdToDefaultPersisterMap.get(objectTypeId);
    }
    
    /**
     * Returns a persister for the given object type id
     * If a persister has not been instantiated, null is returned
     * 
     * @param objectTypeId
     * @return the persister
     */
    public ModelObjectPersister getPersister(String objectTypeId)
    {
        return (ModelObjectPersister) typeIdToMultiPersisterMap.get(objectTypeId);
    }
    
    /**
     * Retrieves the id of the persister for the given object type id
     * 
     * @param objectTypeId
     * @return the persister id
     */
    public String getPersisterId(String objectTypeId)
    {
        ModelObjectPersister persister = getPersister(objectTypeId);
        return persister.getId();
    }
    
    /**
     * Returns an array of all persisters
     * 
     * @return the array
     */
    public ModelObjectPersister[] getPersisters()
    {
        return this.typeIdToMultiPersisterMap.values().toArray(new ModelObjectPersister[this.typeIdToMultiPersisterMap.size()]);
    }
    
    /**
     * Returns a Persister implementation by persister id
     * 
     * @param persisterId
     * @return
     */
    public ModelObjectPersister getPersisterById(String persisterId)
    {
       return (ModelObjectPersister) this.persisterIdToPersisterMap.get(persisterId); 
    }
    
    /**
     * Inits the persisters.
     */
    public void initPersisters()
    {
        // initialize the multi persisters map
        typeIdToMultiPersisterMap = new HashMap<String, ModelObjectPersister>(16, 1.0f);
        
        // initialize the default persisters map
        typeIdToDefaultPersisterMap = new HashMap<String, ModelObjectPersister>(16, 1.0f);
        
        // initialize the
        persisterIdToPersisterMap = new HashMap<String, ModelObjectPersister>(16, 1.0f);

        // walk over the model types and prepare persisters for each
        WebFrameworkConfigElement wfConfig = getWebFrameworkConfig();
        String[] typeIds = wfConfig.getTypeIds();
        for(int i = 0; i < typeIds.length; i++)
        {
            if(logger.isDebugEnabled())
                logger.debug("Initializing model type: " + typeIds[i]);

            TypeDescriptor descriptor = wfConfig.getTypeDescriptor(typeIds[i]);
            
            // get the default store id
            String defaultStoreId = descriptor.getDefaultStoreId();
            Store defaultStore = (Store) getApplicationContext().getBean(defaultStoreId);
            boolean addedDefaultStore = false;
            
            // get the search path
            String searchPathId = descriptor.getSearchPathId();
            SearchPath searchPath = (SearchPath) getApplicationContext().getBean(searchPathId);
            if(searchPath != null)
            {            
                // walk the stores in this search path
                // create persisters for each
                // store into a map keyed by store base path
                Map<String, ModelObjectPersister> persisters = new HashMap<String, ModelObjectPersister>(16, 1.0f);
                for (Store store : searchPath.getStores())
                {
                    ModelObjectPersister persister = null;
                    if(store instanceof RemoteStore)
                    {
                        persister = new RemoteStoreModelObjectPersister(typeIds[i], store);
                    }
                    else
                    {
                        persister = new StoreModelObjectPersister(typeIds[i], store);
                    }
                    persisters.put(persister.getId(), persister);
                    
                    // add to persister id map
                    persisterIdToPersisterMap.put(persister.getId(), persister);

                    // check whether this is the default store
                    if(store.equals(defaultStore))
                    {
                        typeIdToDefaultPersisterMap.put(typeIds[i], persister);
                        addedDefaultStore = true;
                    }
                }
                
                // wrap all of these persisters into a single multi persister
                // and store onto map (keyed by type id)
                ModelObjectPersister persister = new MultiModelObjectPersister(typeIds[i], this, persisters);
                typeIdToMultiPersisterMap.put(typeIds[i], persister);
                
                // debug
                if(!addedDefaultStore)
                {
                    if(logger.isDebugEnabled())
                        logger.debug("Unable to add default store persister for object type id: " + typeIds[i]);                                             
                }
            }
        }
    }
}
