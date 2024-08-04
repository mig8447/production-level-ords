DECLARE
  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;

BEGIN
  ORDS.CREATE_ROLE(p_role_name => 'oracle.dbtools.role.autorest.DEMO_01');
  ORDS.CREATE_ROLE(p_role_name => 'oracle.dbtools.role.autorest.DEMO_01.TASKS');
  ORDS.CREATE_ROLE(p_role_name => 'oracle.dbtools.role.autorest.DEMO_01.TASK_LISTS');
    
  l_roles(1) := 'oracle.dbtools.autorest.any.schema';
  l_roles(2) := 'oracle.dbtools.role.autorest.DEMO_01';
  l_patterns(1) := '/metadata-catalog/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.dbtools.autorest.privilege.DEMO_01',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'DEMO_01 metadata-catalog access',
      p_description    => 'Provides access to the metadata catalog of the objects in the DEMO_01 schema.',
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;
    
  l_roles(1) := 'oracle.dbtools.autorest.any.schema';
  l_roles(2) := 'oracle.dbtools.role.autorest.DEMO_01.TASKS';
  l_patterns(1) := '/metadata-catalog/tasks/*';
  l_patterns(2) := '/tasks/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.dbtools.autorest.privilege.DEMO_01.TASKS',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'DEMO_01.TASKS access',
      p_description    => 'Provides access to the TASKS TABLE in the DEMO_01 schema.',
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;
    
  l_roles(1) := 'oracle.dbtools.autorest.any.schema';
  l_roles(2) := 'oracle.dbtools.role.autorest.DEMO_01.TASK_LISTS';
  l_patterns(1) := '/metadata-catalog/task_lists/*';
  l_patterns(2) := '/task_lists/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.dbtools.autorest.privilege.DEMO_01.TASK_LISTS',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'DEMO_01.TASK_LISTS access',
      p_description    => 'Provides access to the TASK_LISTS TABLE in the DEMO_01 schema.',
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;
    
  l_roles(1) := 'SODA Developer';
  l_patterns(1) := '/soda/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.soda.privilege.developer',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => NULL,
      p_description    => NULL,
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;
    
  ORDS_METADATA.ORDS.ENABLE_OBJECT(
      p_enabled => TRUE, 
      p_schema => 'DEMO_01',
      p_object => 'TASKS',
      p_object_type => 'TABLE',
      p_object_alias => 'tasks',
      p_auto_rest_auth => TRUE);

  ORDS_METADATA.ORDS.ENABLE_OBJECT(
      p_enabled => TRUE, 
      p_schema => 'DEMO_01',
      p_object => 'TASK_LISTS',
      p_object_type => 'TABLE',
      p_object_alias => 'task_lists',
      p_auto_rest_auth => TRUE);

    
  ORDS_METADATA.OAUTH.IMPORT_CLIENT(
      p_name             => 'api-client',
      p_client_id        => 'jvxjmUP2uqwpyclIIG-7cw..',
      p_grant_type       => 'client_credentials',
      p_owner            => 'DEMO_01',
      p_description      => 'A client for tasks and task lists',
      p_origins_allowed  => NULL,
      p_redirect_uri     => NULL,
      p_support_email    => 'noreply@oracle.com',
      p_support_uri      => 'https://support.oracle.com',
      p_token_duration   => NULL,
      p_refresh_duration => NULL,
      p_code_duration    => NULL,
      p_privilege_names  => 'oracle.dbtools.autorest.privilege.DEMO_01.TASKS,oracle.dbtools.autorest.privilege.DEMO_01.TASK_LISTS');

  ORDS_METADATA.OAUTH.GRANT_CLIENT_ROLE( 
      p_client_name     => 'api-client',
      p_role_name => 'oracle.dbtools.role.autorest.DEMO_01.TASKS'); 

  ORDS_METADATA.OAUTH.GRANT_CLIENT_ROLE( 
      p_client_name     => 'api-client',
      p_role_name => 'oracle.dbtools.role.autorest.DEMO_01.TASK_LISTS'); 
      
COMMIT;

END;
/
