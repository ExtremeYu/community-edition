<import resource="classpath:alfresco/enterprise/webscripts/org/alfresco/enterprise/repository/admin/admin-common.lib.js">

/**
 * Repository Admin Console
 * 
 * Root page GET method
 */
function main()
{
   status.code = 301;
   status.location = url.serviceContext + Admin.getDefaultToolURI();
   status.redirect = true;
}

main();