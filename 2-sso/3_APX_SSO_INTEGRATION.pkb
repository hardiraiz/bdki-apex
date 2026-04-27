create or replace package body "APX_SSO_INTEGRATIONS" 
as
    l_sso_base_url VARCHAR2(500) := 'https://test.com';

    FUNCTION GET_ACCESS_TOKEN (P_TIMESTAMP IN VARCHAR2)
        RETURN VARCHAR2
    AS

    BEGIN
        NULL;
    END GET_ACCESS_TOKEN;


end "APX_SSO_INTEGRATIONS";
/