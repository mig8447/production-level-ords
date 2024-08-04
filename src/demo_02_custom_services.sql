DECLARE
  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;

BEGIN
  ORDS.DEFINE_MODULE(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_base_path      => '/api/',
      p_items_per_page => 25,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'task_lists/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'task_lists/',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'SELECT
    -- Dado que se están seleccionando columnas adicionales al total de columnas
    -- se debe utilizar el prefijo del esquema antes del asterisco
    TASK_LISTS.*,
    -- Los valores de las columnas con aliases entre comillas que comiencen por
    -- "$" son usados como links en cada uno de los registros de la colección
    -- el valor será la ruta relativa desde la URI de este servicio
    TASK_LISTS.ID AS "$self"
FROM
    -- Las consultas de tipo colección o item omiten el punto y coma final
    TASK_LISTS');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'task_lists/',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'DECLARE
    L_TASK_LIST_ID NUMBER;
    L_ERROR_RESPONSE JSON_OBJECT_T := JSON_OBJECT_T();
BEGIN
    INSERT INTO
        TASK_LISTS(
            TITLE,
            DESCRIPTION,
            CREATED_BY
        ) VALUES (
            :title,
            :description,
            :current_user
        )
        RETURNING ID INTO L_TASK_LIST_ID;

    -- Asignar el estado HTTP a 201 - Created
    :status_code := 201;
    -- Asignar la ruta relativa a la que ORDS hará una petición GET para
    -- obtener una respuesta. En este caso usaremos la ruta que redirige a
    -- obtener la lista de tareas creada
    :forward_location := L_TASK_LIST_ID;
EXCEPTION
    WHEN OTHERS THEN
        -- Asignar el estado HTTP a 400 - Bad Request
        :status_code := 400;
        -- Ver https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/OWA_UTIL.html#GUID-950D2D77-6D1E-4548-9865-D325C40B244B
        -- Set response Content-Type to JSON and close the HTTP headers
        OWA_UTIL.MIME_HEADER( c' || 'content_type => ''application/json'', bclose_header => true );
        L_ERROR_RESPONSE.PUT( ''error'', ''An error occurred while creating the task list'' );
        -- Imprimir el string JSON al stream HTTP
        HTP.P( L_ERROR_RESPONSE.TO_STRING() );
END;');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'task_lists/:task_list_id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'task_lists/:task_list_id',
      p_method         => 'GET',
      p_source_type    => 'json/item',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'SELECT
    TASK_LISTS.*,
    TASK_LISTS.ID AS "$self"
FROM
    TASK_LISTS
WHERE
    ID = :task_list_id');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'task_lists/:task_list_id',
      p_method         => 'PUT',
      p_source_type    => 'plsql/block',
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'DECLARE
    L_ERROR_RESPONSE JSON_OBJECT_T := JSON_OBJECT_T();
BEGIN
    UPDATE
        TASK_LISTS
    SET
        TITLE = :title,
        DESCRIPTION = :description,
        UPDATED_BY = :current_user
    WHERE
        ID = :task_list_id;

    -- Asignar el estado HTTP a 200 - OK
    :status_code := 200;
    -- Asignar la ruta relativa a la que ORDS hará una petición GET para
    -- obtener una respuesta. En este caso usaremos la ruta que redirige a
    -- obtener la tarea creada
    :forward_location := ''.'';
EXCEPTION
    WHEN OTHERS THEN
        -- Asignar el estado HTTP a 400 - Bad Request
        :status_code := 400;
        -- Ver https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/OWA_UTIL.html#GUID-950D2D77-6D1E-4548-9865-D325C40B244B
        -- Set response Content-Type to JSON and close the HTTP headers
        OWA_UTIL.MIME_HEADER( ccontent_type => ''application/json'', bclose_header => true );
        L_ERROR_RESPONSE.PUT( ''error'', ''An error occurred while upd' || 'ating the task list'' );
        -- Imprimir el string JSON al stream HTTP
        HTP.P( L_ERROR_RESPONSE.TO_STRING() );
END;');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'task_lists/:task_list_id',
      p_method         => 'DELETE',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'DECLARE
    L_ERROR_RESPONSE JSON_OBJECT_T := JSON_OBJECT_T();
BEGIN
    DELETE FROM
        TASK_LISTS
    WHERE
        ID = :task_list_id;

    -- Asignar el estado HTTP a 204 - No Content
    :status_code := 204;
    -- Dado el status, no se imprime ni devuelve ningun cuerpo en la respuesta
EXCEPTION
    WHEN OTHERS THEN
        -- Asignar el estado HTTP a 400 - Bad Request
        :status_code := 400;
        -- Ver https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/OWA_UTIL.html#GUID-950D2D77-6D1E-4548-9865-D325C40B244B
        -- Set response Content-Type to JSON and close the HTTP headers
        OWA_UTIL.MIME_HEADER( ccontent_type => ''application/json'', bclose_header => true );
        L_ERROR_RESPONSE.PUT( ''error'', ''An error occurred while deleting the task list. '' || SQLERRM );
        HTP.P( L_ERROR_RESPONSE.TO_STRING() );
END;');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'tasks/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'tasks/',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'SELECT
    TASKS.*,
    TASKS.ID AS "$self",
    -- Se pueden usar rutas relativas y alias distintos
    ''../task_lists/'' || TASKS.TASK_LIST_ID AS "$task_list"
FROM
    TASKS');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'tasks/',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'DECLARE
    L_TASK_ID NUMBER;
    L_ERROR_RESPONSE JSON_OBJECT_T := JSON_OBJECT_T();
BEGIN
    INSERT INTO
        TASKS(
            TITLE,
            DESCRIPTION,
            START_DATE,
            DUE_DATE,
            TASK_LIST_ID,
            CREATED_BY
        ) VALUES (
            :title,
            :description,
            :start_date,
            :due_date,
            :task_list_id,
            :current_user
        )
        RETURNING ID INTO L_TASK_ID;

    -- Asignar el estado HTTP a 201 - Created
    :status_code := 201;
    -- Asignar la ruta relativa a la que ORDS hará una petición GET para
    -- obtener una respuesta. En este caso usaremos la ruta que redirige a
    -- obtener la lista de tareas creada
    :forward_location := L_TASK_ID;
EXCEPTION
    WHEN OTHERS THEN
        -- Asignar el estado HTTP a 400 - Bad Request
        :status_code := 400;
        -- Ver https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/OWA_UTIL.html#GUID-950D2D77-6D1E' || '-4548-9865-D325C40B244B
        -- Set response Content-Type to JSON and close the HTTP headers
        OWA_UTIL.MIME_HEADER( ccontent_type => ''application/json'', bclose_header => true );
        L_ERROR_RESPONSE.PUT( ''error'', ''An error occurred while creating the task list'' );
        -- Imprimir el string JSON al stream HTTP
        HTP.P( L_ERROR_RESPONSE.TO_STRING() );
END;');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'tasks/:task_id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'tasks/:task_id',
      p_method         => 'GET',
      p_source_type    => 'json/item',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'SELECT
    TASKS.*,
    TASKS.ID AS "$self",
    ''../task_lists/'' || TASKS.TASK_LIST_ID AS "$task_list"
FROM
    TASKS
WHERE
    ID = :task_id');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'tasks/:task_id',
      p_method         => 'PUT',
      p_source_type    => 'plsql/block',
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'DECLARE
    L_ERROR_RESPONSE JSON_OBJECT_T := JSON_OBJECT_T();
BEGIN
    UPDATE
        TASKS
    SET
        TITLE = :title,
        DESCRIPTION = :description,
        START_DATE = :start_date,
        DUE_DATE = :due_date,
        IS_DONE = :is_done,
        TASK_LIST_ID = :task_list_id,
        UPDATED_BY = :current_user
    WHERE
        ID = :task_id;

    -- Asignar el estado HTTP a 200 - OK
    :status_code := 200;
    -- Asignar la ruta relativa a la que ORDS hará una petición GET para
    -- obtener una respuesta. En este caso usaremos la ruta que redirige a
    -- obtener la lista de tareas creada
    :forward_location := ''.'';
EXCEPTION
    WHEN OTHERS THEN
        -- Asignar el estado HTTP a 400 - Bad Request
        :status_code := 400;
        -- Ver https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/OWA_UTIL.html#GUID-950D2D77-6D1E-4548-9865-D325C40B244B
        -- Set response Content-Type to JSON and close the HTTP headers
        OWA_UTIL.MIME_HEADER(' || ' ccontent_type => ''application/json'', bclose_header => true );
        L_ERROR_RESPONSE.PUT( ''error'', ''An error occurred while updating the task list'' );
        -- Imprimir el string JSON al stream HTTP
        HTP.P( L_ERROR_RESPONSE.TO_STRING() );
END;');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'com.oracle.apex.office-hours.production-level-ords',
      p_pattern        => 'tasks/:task_id',
      p_method         => 'DELETE',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'DECLARE
    L_ERROR_RESPONSE JSON_OBJECT_T := JSON_OBJECT_T();
BEGIN
    DELETE FROM
        TASKS
    WHERE
        ID = :task_id;

    -- Asignar el estado HTTP a 204 - No Content
    :status_code := 204;
    -- Dado el status, no se imprime ni devuelve ningun cuerpo en la respuesta
EXCEPTION
    WHEN OTHERS THEN
        -- Asignar el estado HTTP a 400 - Bad Request
        :status_code := 400;
        -- Ver https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/OWA_UTIL.html#GUID-950D2D77-6D1E-4548-9865-D325C40B244B
        -- Set response Content-Type to JSON and close the HTTP headers
        OWA_UTIL.MIME_HEADER( ccontent_type => ''application/json'', bclose_header => true );
        L_ERROR_RESPONSE.PUT( ''error'', ''An error occurred while deleting the task list'' );
        HTP.P( L_ERROR_RESPONSE.TO_STRING() );
END;');

    
  ORDS.CREATE_ROLE(p_role_name => 'TASKS_API_ROLE');
  ORDS.CREATE_ROLE(p_role_name => 'oracle.dbtools.role.autorest.DEMO_02');
    
  l_roles(1) := 'TASKS_API_ROLE';
  l_modules(1) := 'com.oracle.apex.office-hours.production-level-ords';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'TASKS_API_PRIVILEGE',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'TASKS_API_PRIVILEGE',
      p_description    => 'Privilege for the tasks API',
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;
    
  l_roles(1) := 'oracle.dbtools.autorest.any.schema';
  l_roles(2) := 'oracle.dbtools.role.autorest.DEMO_02';
  l_patterns(1) := '/metadata-catalog/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.dbtools.autorest.privilege.DEMO_02',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'DEMO_02 metadata-catalog access',
      p_description    => 'Provides access to the metadata catalog of the objects in the DEMO_02 schema.',
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
    
    
  ORDS_METADATA.OAUTH.IMPORT_CLIENT(
      p_name             => 'api-client',
      p_client_id        => 'QMN-I70qZeDRJwglS51DTg..',
      p_grant_type       => 'client_credentials',
      p_owner            => 'DEMO_02',
      p_description      => 'Client for the tasks API',
      p_origins_allowed  => NULL,
      p_redirect_uri     => NULL,
      p_support_email    => 'noreply@oracle.com',
      p_support_uri      => 'https://support.oracle.com',
      p_token_duration   => NULL,
      p_refresh_duration => NULL,
      p_code_duration    => NULL,
      p_privilege_names  => 'TASKS_API_PRIVILEGE');

  ORDS_METADATA.OAUTH.GRANT_CLIENT_ROLE( 
      p_client_name     => 'api-client',
      p_role_name => 'TASKS_API_ROLE'); 
      
COMMIT;

END;
/