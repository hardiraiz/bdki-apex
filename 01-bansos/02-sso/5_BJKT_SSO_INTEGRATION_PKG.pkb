create or replace package body "BJKT_SSO_INTEGRATIONS_PKG" 
as
    L_BANK_JKT    VARCHAR2 (100) := 'BJKT';
    L_API_GROUP   VARCHAR2 (100) := '/service-sso/';

    PROCEDURE IFACE_LOG (
        P_LOG       IN  BJKT_API_LOG%ROWTYPE,
        X_LOG_ID    OUT VARCHAR2,
        X_STATUS    OUT VARCHAR2
    ) IS
    BEGIN
        INSERT INTO BJKT_API_LOG (
            NAME,
            URL,
            CONTENT_TYPE,
            AUTHORIZATION,
            PARTNER_ID,
            TIME_STAMP,
            SIGNATURE,
            EXTERNAL_ID,
            CHANNEL_ID,
            RAY_ID,
            ACCESS_TOKEN,
            HEADER,
            REQUEST,
            RESPONSE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            IFACE_MODE,
            IFACE_STATUS,
            IFACE_MESSAGE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATE_LOGIN,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
        ) VALUES (
            P_LOG.NAME,
            P_LOG.URL,
            P_LOG.CONTENT_TYPE,
            P_LOG.AUTHORIZATION,
            P_LOG.PARTNER_ID,
            P_LOG.TIME_STAMP,
            P_LOG.SIGNATURE,
            P_LOG.EXTERNAL_ID,
            P_LOG.CHANNEL_ID,
            P_LOG.RAY_ID,
            P_LOG.ACCESS_TOKEN,
            P_LOG.HEADER,
            P_LOG.REQUEST,
            P_LOG.RESPONSE,
            P_LOG.ATTRIBUTE_CATEGORY,
            P_LOG.ATTRIBUTE1,
            P_LOG.ATTRIBUTE2,
            P_LOG.ATTRIBUTE3,
            P_LOG.ATTRIBUTE4,
            P_LOG.ATTRIBUTE5,
            P_LOG.ATTRIBUTE6,
            P_LOG.ATTRIBUTE7,
            P_LOG.ATTRIBUTE8,
            P_LOG.ATTRIBUTE9,
            P_LOG.ATTRIBUTE10,
            P_LOG.ATTRIBUTE11,
            P_LOG.ATTRIBUTE12,
            P_LOG.ATTRIBUTE13,
            P_LOG.ATTRIBUTE14,
            P_LOG.ATTRIBUTE15,
            P_LOG.IFACE_MODE,
            P_LOG.IFACE_STATUS,
            P_LOG.IFACE_MESSAGE,
            P_LOG.CREATED_BY,
            P_LOG.CREATION_DATE,
            P_LOG.LAST_UPDATE_LOGIN,
            P_LOG.LAST_UPDATED_BY,
            P_LOG.LAST_UPDATE_DATE
        ) RETURNING LOG_ID INTO X_LOG_ID;

        X_STATUS := 'SUCCESS';

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            X_LOG_ID := NULL;
            X_STATUS := 'ERROR';
    END IFACE_LOG;

    FUNCTION GET_EXIST_TOKEN RETURN VARCHAR2
    IS
        L_ACCESS_TOKEN      VARCHAR2(4000);
        L_TIMESTAMP_TOKEN   VARCHAR2(200);
        L_EXPIRED_IN        NUMBER;
    BEGIN
        SELECT ACCESS_TOKEN, TIMESTAMP_TOKEN, EXPIRED_IN
        INTO L_ACCESS_TOKEN, L_TIMESTAMP_TOKEN, L_EXPIRED_IN
        FROM BJKT_ACCESS_TOKEN
        WHERE NAME = L_BANK_JKT
        ORDER BY ID DESC
        FETCH FIRST 1 ROW ONLY;

        IF SYSTIMESTAMP > 
            (TO_TIMESTAMP_TZ(L_TIMESTAMP_TOKEN, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') 
            + NUMTODSINTERVAL(L_EXPIRED_IN - 60, 'SECOND'))
        THEN
            RETURN NULL;
        END IF;

        RETURN L_ACCESS_TOKEN;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END;


    FUNCTION GET_ACCESS_TOKEN (P_TIMESTAMP IN VARCHAR2)
        RETURN VARCHAR2
    AS
        L_TIMESTAMP             VARCHAR2 (200);
        L_CLIENT_ID             VARCHAR2 (1000);
        L_PRIVATE_KEY           VARCHAR2 (4000);
        L_URL                   VARCHAR2 (4000);
        L_PATH                  VARCHAR2 (4000) DEFAULT 'get-token';
        L_WALLET_PATH           VARCHAR2 (4000);
        L_WALLET_PASSWORD       VARCHAR2 (4000);
        L_CLEAN_KEY             VARCHAR2 (4000);
        L_STRINGTOSIGN          VARCHAR2 (4000);
        L_SIGNATURE             VARCHAR2 (4000);
        L_RAY_ID                VARCHAR2 (20);
        L_BODY                  CLOB;
        L_RESULT_CLOB           CLOB;
        L_HEADER                CLOB;
        L_TOKEN                 VARCHAR2 (4000);
        L_RESPONSE_CODE         NUMBER;
        -- L_RESPONSE_STATUS       BOOLEAN;
        -- L_RESPONSE_STATUS_CODE  VARCHAR2 (4000);
        L_RESPONSE_TIMESTAMP    VARCHAR2 (200);
        L_EXPIRED_IN            NUMBER;

        L_LOG                   BJKT_API_LOG%ROWTYPE;
        L_LOG_ID                VARCHAR2 (100);
        L_LOG_STATUS            VARCHAR2 (100);
    BEGIN
        L_TOKEN := GET_EXIST_TOKEN();
        IF L_TOKEN IS NOT NULL THEN 
            RETURN L_TOKEN;
        END IF;

        -- Continue to generate access token when existing token expired or not exists
        L_TIMESTAMP := P_TIMESTAMP;

        SELECT CLIENT_ID,
               URL,
               WALLET_PATH,
               WALLET_PASSWORD
          INTO L_CLIENT_ID,
               L_URL,
               L_WALLET_PATH,
               L_WALLET_PASSWORD
        FROM BJKT_FND_CREDENTIAL
        WHERE NAME = L_BANK_JKT
        FETCH FIRST 1 ROW ONLY;

        L_STRINGTOSIGN := L_CLIENT_ID || '|' || L_TIMESTAMP;

        L_SIGNATURE :=
            BJKT_JAVA_PKG.HASH256 (
                P_INPUT   => L_STRINGTOSIGN
            );
        
        L_RAY_ID := BJKT_JAVA_PKG.GET_RAY_ID();

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;

        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).NAME     := 'Content-Type';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE    := 'application/json';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).NAME     := 'X-TIMESTAMP';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE    := L_TIMESTAMP;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).NAME     := 'X-CHANNEL-KEY';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE    := L_CLIENT_ID;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).NAME     := 'X-SIGNATURE';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE    := L_SIGNATURE;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).NAME     := 'X-RAY-ID';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE    := L_RAY_ID;

        FOR I IN 1 .. APEX_WEB_SERVICE.G_REQUEST_HEADERS.COUNT
        LOOP
            L_HEADER := L_HEADER
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).NAME
                        || ': '
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).VALUE
                        || CHR (10);
        END LOOP;

        -- L_BODY := '{ "grantType": "client_credentials" }';

        L_RESULT_CLOB :=
            APEX_WEB_SERVICE.MAKE_REST_REQUEST (
                P_URL           => L_URL || L_API_GROUP || L_PATH,
                P_HTTP_METHOD   => 'POST'
                -- P_BODY          => L_BODY
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
            );

        L_RESPONSE_CODE := APEX_WEB_SERVICE.G_STATUS_CODE;

        IF L_RESPONSE_CODE <> 200 
        THEN
            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MESSAGE := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;
            L_LOG.IFACE_MODE    := 'POST';

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.RAY_ID        := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

            RETURN NULL;
        END IF;
        
        APEX_JSON.PARSE (L_RESULT_CLOB);

        L_TOKEN                 := APEX_JSON.GET_VARCHAR2 (P_PATH => 'result.access_token');
        -- L_RESPONSE_STATUS       := APEX_JSON.GET_BOOLEAN  (P_PATH => 'status');
        -- L_RESPONSE_STATUS_CODE  := APEX_JSON.GET_VARCHAR2 (P_PATH => 'statusCode');
        L_RESPONSE_TIMESTAMP    := APEX_JSON.GET_VARCHAR2 (P_PATH => 'result.timestamp');
        L_EXPIRED_IN            := APEX_JSON.GET_NUMBER   (P_PATH => 'result.expires_in');

        INSERT INTO BJKT_ACCESS_TOKEN (
            NAME, ACCESS_TOKEN, TIMESTAMP_TOKEN, EXPIRED_IN
        ) VALUES (
            L_BANK_JKT, L_TOKEN, L_RESPONSE_TIMESTAMP, L_EXPIRED_IN
        );

        COMMIT;

        RETURN L_TOKEN;

    EXCEPTION
        WHEN OTHERS THEN
            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.HEADER        := L_HEADER;

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MODE    := 'POST';
            L_LOG.IFACE_MESSAGE := SQLERRM;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

            RETURN NULL;

    END GET_ACCESS_TOKEN;

    PROCEDURE GET_DIVISIONS (
        R_STATUS    OUT VARCHAR2,
        R_MESSAGE   OUT VARCHAR2
    ) 
    IS
        L_PATH                  VARCHAR2(1000) DEFAULT 'api/v3/get-list-all-divisi';
        L_TIMESTAMP             VARCHAR2(200);
        L_TOKEN                 VARCHAR2(4000);
        L_CLIENT_ID             VARCHAR2(1000);
        L_CLIENT_KEY            VARCHAR2(4000);
        L_SIGNATURE             VARCHAR2(4000);
        L_RAY_ID                VARCHAR2(20);
        L_HEADER                CLOB;
        L_BODY                  CLOB;
        L_RESULT_CLOB           CLOB;
        L_URL                   VARCHAR2(4000);
        L_WALLET_PATH           VARCHAR2(4000);
        L_WALLET_PASSWORD       VARCHAR2(4000);
        L_RESPONSE_CODE         NUMBER;
        -- L_RESPONSE_STATUS       BOOLEAN;
        -- L_RESPONSE_STATUS_CODE  VARCHAR2(200);

        L_LOG                   BJKT_API_LOG%ROWTYPE;
        L_LOG_ID                VARCHAR2 (100);
        L_LOG_STATUS            VARCHAR2 (100);
    BEGIN
        SELECT CLIENT_ID,
               CLIENT_KEY,
               URL,
               WALLET_PATH,
               WALLET_PASSWORD
          INTO L_CLIENT_ID,
               L_CLIENT_KEY,
               L_URL,
               L_WALLET_PATH,
               L_WALLET_PASSWORD
        FROM BJKT_FND_CREDENTIAL
        WHERE NAME = L_BANK_JKT
        FETCH FIRST 1 ROW ONLY;

        L_TIMESTAMP := TO_CHAR (SYSTIMESTAMP, 'rrrr-mm-dd') 
                        || 'T'
                        || TO_CHAR (SYSTIMESTAMP, 'hh24:mi:ssTZR');

        L_TOKEN     := GET_ACCESS_TOKEN(L_TIMESTAMP);
        L_RAY_ID    := BJKT_JAVA_PKG.GET_RAY_ID();

        L_SIGNATURE :=
            BJKT_JAVA_PKG.SNAP_SIGNATURE_SHA512HMAC (
                P_CLIENT_SECRET   => L_CLIENT_KEY,
                P_HTTP_METHOD     => 'GET',
                P_URL_X           => '/service-sso/' || L_PATH,
                P_TOKEN           => L_TOKEN,
                P_REQUEST_BODY    => NULL,
                P_TIMESTAMP       => L_TIMESTAMP
            );

        -- DBMS_OUTPUT.PUT_LINE('P_CLIENT_SECRET : ' || L_CLIENT_KEY);
        -- DBMS_OUTPUT.PUT_LINE('P_HTTP_METHOD   : ' || 'GET');
        -- DBMS_OUTPUT.PUT_LINE('P_URL_X         : ' || '/' || L_PATH);
        -- DBMS_OUTPUT.PUT_LINE('P_TOKEN         : ' || L_TOKEN);
        -- DBMS_OUTPUT.PUT_LINE('P_REQUEST_BODY  : ' || NULL);
        -- DBMS_OUTPUT.PUT_LINE('P_TIMESTAMP     : ' || L_TIMESTAMP);

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;

        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).NAME     := 'Content-Type';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE    := 'application/json';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).NAME     := 'Authorization';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE    := 'Bearer ' || L_TOKEN;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).NAME     := 'X-TIMESTAMP';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE    := L_TIMESTAMP;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).NAME     := 'X-CHANNEL-KEY';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE    := L_CLIENT_ID;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).NAME     := 'X-SIGNATURE';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE    := L_SIGNATURE;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).NAME     := 'X-RAY-ID';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).VALUE    := L_RAY_ID;

        FOR I IN 1 .. APEX_WEB_SERVICE.G_REQUEST_HEADERS.COUNT
        LOOP
            L_HEADER := L_HEADER
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).NAME
                        || ': '
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).VALUE
                        || CHR (10);
        END LOOP;

        L_RESULT_CLOB :=
            APEX_WEB_SERVICE.MAKE_REST_REQUEST (
                P_URL           => L_URL || L_API_GROUP || L_PATH,
                P_HTTP_METHOD   => 'GET'
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
            );

        L_RESPONSE_CODE := APEX_WEB_SERVICE.G_STATUS_CODE;

        IF L_RESPONSE_CODE <> 200
        THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MESSAGE := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;
            L_LOG.IFACE_MODE    := 'GET';

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

            RETURN;
        END IF;

        APEX_JSON.PARSE (L_RESULT_CLOB);

        -- L_RESPONSE_STATUS       := APEX_JSON.GET_BOOLEAN (P_PATH => 'status');
        -- L_RESPONSE_STATUS_CODE  := APEX_JSON.GET_VARCHAR2 (P_PATH => 'statusCode');

        -- Delete semua data lama sebelum insert
        DELETE FROM BJKT_DIVISIONS;

        -- Insert dari response JSON menggunakan JSON_TABLE
        FOR rec IN (
            SELECT *
            FROM JSON_TABLE(
                L_RESULT_CLOB,
                '$.result[*]'
                COLUMNS (
                    id           NUMBER         PATH '$.id' NULL ON ERROR,
                    id_divisi    NUMBER         PATH '$.id_divisi' NULL ON ERROR,
                    nama_divisi  VARCHAR2(4000) PATH '$.nama_divisi' NULL ON ERROR,
                    status_data  NUMBER         PATH '$.status_data' NULL ON ERROR
                )
            )
        )
        LOOP
            INSERT INTO BJKT_DIVISIONS (
                ID, 
                DIVISION_ID, 
                DIVISION_NAME,
                STATUS_DATA
            ) VALUES (
                rec.id,
                rec.id_divisi,
                rec.nama_divisi,
                rec.status_data
            );
        END LOOP;

        R_STATUS    := 'SUCCESS';
        R_MESSAGE   := 'Get data divisions successfully';

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := SQLERRM;

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MODE    := 'GET';
            L_LOG.IFACE_MESSAGE := SQLERRM;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

    END GET_DIVISIONS;

    PROCEDURE GET_DEPARTMENTS (
        R_STATUS    OUT VARCHAR2,
        R_MESSAGE   OUT VARCHAR2
    ) 
    IS
        L_PATH                  VARCHAR2(1000) DEFAULT 'api/v3/get-list-all-departemen';
        L_TIMESTAMP             VARCHAR2(200);
        L_TOKEN                 VARCHAR2(4000);
        L_CLIENT_ID             VARCHAR2(1000);
        L_CLIENT_KEY            VARCHAR2(4000);
        L_SIGNATURE             VARCHAR2(4000);
        L_RAY_ID                VARCHAR2(20);
        L_HEADER                CLOB;
        L_BODY                  CLOB;
        L_RESULT_CLOB           CLOB;
        L_URL                   VARCHAR2(4000);
        L_WALLET_PATH           VARCHAR2(4000);
        L_WALLET_PASSWORD       VARCHAR2(4000);
        L_RESPONSE_CODE         NUMBER;
        -- L_RESPONSE_STATUS       BOOLEAN;
        -- L_RESPONSE_STATUS_CODE  VARCHAR2(200);

        L_LOG                   BJKT_API_LOG%ROWTYPE;
        L_LOG_ID                VARCHAR2 (100);
        L_LOG_STATUS            VARCHAR2 (100);
    BEGIN
        SELECT CLIENT_ID,
               CLIENT_KEY,
               URL,
               WALLET_PATH,
               WALLET_PASSWORD
          INTO L_CLIENT_ID,
               L_CLIENT_KEY,
               L_URL,
               L_WALLET_PATH,
               L_WALLET_PASSWORD
        FROM BJKT_FND_CREDENTIAL
        WHERE NAME = L_BANK_JKT
        FETCH FIRST 1 ROW ONLY;

        L_TIMESTAMP := TO_CHAR (SYSTIMESTAMP, 'rrrr-mm-dd') 
                        || 'T'
                        || TO_CHAR (SYSTIMESTAMP, 'hh24:mi:ssTZR');

        L_TOKEN     := GET_ACCESS_TOKEN(L_TIMESTAMP);
        L_RAY_ID    := BJKT_JAVA_PKG.GET_RAY_ID();

        L_SIGNATURE :=
            BJKT_JAVA_PKG.SNAP_SIGNATURE_SHA512HMAC (
                P_CLIENT_SECRET   => L_CLIENT_KEY,
                P_HTTP_METHOD     => 'GET',
                P_URL_X           => '/service-sso/' || L_PATH,
                P_TOKEN           => L_TOKEN,
                P_REQUEST_BODY    => NULL,
                P_TIMESTAMP       => L_TIMESTAMP
            );

        -- DBMS_OUTPUT.PUT_LINE('P_CLIENT_SECRET : ' || L_CLIENT_KEY);
        -- DBMS_OUTPUT.PUT_LINE('P_HTTP_METHOD   : ' || 'GET');
        -- DBMS_OUTPUT.PUT_LINE('P_URL_X         : ' || '/' || L_PATH);
        -- DBMS_OUTPUT.PUT_LINE('P_TOKEN         : ' || L_TOKEN);
        -- DBMS_OUTPUT.PUT_LINE('P_REQUEST_BODY  : ' || NULL);
        -- DBMS_OUTPUT.PUT_LINE('P_TIMESTAMP     : ' || L_TIMESTAMP);

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;

        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).NAME     := 'Content-Type';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE    := 'application/json';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).NAME     := 'Authorization';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE    := 'Bearer ' || L_TOKEN;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).NAME     := 'X-TIMESTAMP';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE    := L_TIMESTAMP;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).NAME     := 'X-CHANNEL-KEY';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE    := L_CLIENT_ID;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).NAME     := 'X-SIGNATURE';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE    := L_SIGNATURE;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).NAME     := 'X-RAY-ID';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).VALUE    := L_RAY_ID;

        FOR I IN 1 .. APEX_WEB_SERVICE.G_REQUEST_HEADERS.COUNT
        LOOP
            L_HEADER := L_HEADER
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).NAME
                        || ': '
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).VALUE
                        || CHR (10);
        END LOOP;

        L_RESULT_CLOB :=
            APEX_WEB_SERVICE.MAKE_REST_REQUEST (
                P_URL           => L_URL || L_API_GROUP || L_PATH,
                P_HTTP_METHOD   => 'GET'
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
            );

        L_RESPONSE_CODE := APEX_WEB_SERVICE.G_STATUS_CODE;

        IF L_RESPONSE_CODE <> 200
        THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MESSAGE := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;
            L_LOG.IFACE_MODE    := 'GET';

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

            RETURN;
        END IF;

        APEX_JSON.PARSE (L_RESULT_CLOB);

        -- L_RESPONSE_STATUS       := APEX_JSON.GET_BOOLEAN (P_PATH => 'status');
        -- L_RESPONSE_STATUS_CODE  := APEX_JSON.GET_VARCHAR2 (P_PATH => 'statusCode');

        -- Delete semua data lama sebelum insert
        DELETE FROM BJKT_DEPARTMENTS;

        -- Insert dari response JSON menggunakan JSON_TABLE
        FOR rec IN (
            SELECT *
            FROM JSON_TABLE(
                L_RESULT_CLOB,
                '$.result[*]'
                COLUMNS (
                    id              NUMBER         PATH '$.id' NULL ON ERROR,
                    id_departemen   NUMBER         PATH '$.id_departemen' NULL ON ERROR,
                    nama_departemen VARCHAR2(4000) PATH '$.nama_departemen' NULL ON ERROR,
                    status_data     NUMBER         PATH '$.status_data' NULL ON ERROR
                )
            )
        )
        LOOP
            INSERT INTO BJKT_DEPARTMENTS (
                ID, 
                DEPARTMENT_ID, 
                DEPARTMENT_NAME,
                STATUS_DATA
            ) VALUES (
                rec.id,
                rec.id_departemen,
                rec.nama_departemen,
                rec.status_data
            );
        END LOOP;

        R_STATUS    := 'SUCCESS';
        R_MESSAGE   := 'Get data departments successfully';

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := SQLERRM;

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MODE    := 'GET';
            L_LOG.IFACE_MESSAGE := SQLERRM;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

    END GET_DEPARTMENTS;

    PROCEDURE GET_POSITIONS (
        R_STATUS    OUT VARCHAR2,
        R_MESSAGE   OUT VARCHAR2
    ) 
    IS
        L_PATH                  VARCHAR2(1000) DEFAULT 'api/v3/get-list-all-jabatan';
        L_TIMESTAMP             VARCHAR2(200);
        L_TOKEN                 VARCHAR2(4000);
        L_CLIENT_ID             VARCHAR2(1000);
        L_CLIENT_KEY            VARCHAR2(4000);
        L_SIGNATURE             VARCHAR2(4000);
        L_RAY_ID                VARCHAR2(20);
        L_HEADER                CLOB;
        L_BODY                  CLOB;
        L_RESULT_CLOB           CLOB;
        L_URL                   VARCHAR2(4000);
        L_WALLET_PATH           VARCHAR2(4000);
        L_WALLET_PASSWORD       VARCHAR2(4000);
        L_RESPONSE_CODE         NUMBER;
        -- L_RESPONSE_STATUS       BOOLEAN;
        -- L_RESPONSE_STATUS_CODE  VARCHAR2(200);

        L_LOG                   BJKT_API_LOG%ROWTYPE;
        L_LOG_ID                VARCHAR2 (100);
        L_LOG_STATUS            VARCHAR2 (100);
    BEGIN
        SELECT CLIENT_ID,
               CLIENT_KEY,
               URL,
               WALLET_PATH,
               WALLET_PASSWORD
          INTO L_CLIENT_ID,
               L_CLIENT_KEY,
               L_URL,
               L_WALLET_PATH,
               L_WALLET_PASSWORD
        FROM BJKT_FND_CREDENTIAL
        WHERE NAME = L_BANK_JKT
        FETCH FIRST 1 ROW ONLY;

        L_TIMESTAMP := TO_CHAR (SYSTIMESTAMP, 'rrrr-mm-dd') 
                        || 'T'
                        || TO_CHAR (SYSTIMESTAMP, 'hh24:mi:ssTZR');

        L_TOKEN     := GET_ACCESS_TOKEN(L_TIMESTAMP);
        L_RAY_ID    := BJKT_JAVA_PKG.GET_RAY_ID();

        L_SIGNATURE :=
            BJKT_JAVA_PKG.SNAP_SIGNATURE_SHA512HMAC (
                P_CLIENT_SECRET   => L_CLIENT_KEY,
                P_HTTP_METHOD     => 'GET',
                P_URL_X           => '/service-sso/' || L_PATH,
                P_TOKEN           => L_TOKEN,
                P_REQUEST_BODY    => NULL,
                P_TIMESTAMP       => L_TIMESTAMP
            );

        -- DBMS_OUTPUT.PUT_LINE('P_CLIENT_SECRET : ' || L_CLIENT_KEY);
        -- DBMS_OUTPUT.PUT_LINE('P_HTTP_METHOD   : ' || 'GET');
        -- DBMS_OUTPUT.PUT_LINE('P_URL_X         : ' || '/' || L_PATH);
        -- DBMS_OUTPUT.PUT_LINE('P_TOKEN         : ' || L_TOKEN);
        -- DBMS_OUTPUT.PUT_LINE('P_REQUEST_BODY  : ' || NULL);
        -- DBMS_OUTPUT.PUT_LINE('P_TIMESTAMP     : ' || L_TIMESTAMP);

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;

        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).NAME     := 'Content-Type';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE    := 'application/json';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).NAME     := 'Authorization';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE    := 'Bearer ' || L_TOKEN;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).NAME     := 'X-TIMESTAMP';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE    := L_TIMESTAMP;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).NAME     := 'X-CHANNEL-KEY';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE    := L_CLIENT_ID;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).NAME     := 'X-SIGNATURE';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE    := L_SIGNATURE;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).NAME     := 'X-RAY-ID';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).VALUE    := L_RAY_ID;

        FOR I IN 1 .. APEX_WEB_SERVICE.G_REQUEST_HEADERS.COUNT
        LOOP
            L_HEADER := L_HEADER
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).NAME
                        || ': '
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).VALUE
                        || CHR (10);
        END LOOP;

        L_RESULT_CLOB :=
            APEX_WEB_SERVICE.MAKE_REST_REQUEST (
                P_URL           => L_URL || L_API_GROUP || L_PATH,
                P_HTTP_METHOD   => 'GET'
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
            );

        L_RESPONSE_CODE := APEX_WEB_SERVICE.G_STATUS_CODE;

        IF L_RESPONSE_CODE <> 200
        THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MESSAGE := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;
            L_LOG.IFACE_MODE    := 'GET';

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

            RETURN;
        END IF;

        APEX_JSON.PARSE (L_RESULT_CLOB);

        -- L_RESPONSE_STATUS       := APEX_JSON.GET_BOOLEAN (P_PATH => 'status');
        -- L_RESPONSE_STATUS_CODE  := APEX_JSON.GET_VARCHAR2 (P_PATH => 'statusCode');

        -- Delete semua data lama sebelum insert
        DELETE FROM BJKT_POSITIONS;

        -- Insert dari response JSON menggunakan JSON_TABLE
        FOR rec IN (
            SELECT *
            FROM JSON_TABLE(
                L_RESULT_CLOB,
                '$.result[*]'
                COLUMNS (
                    id              NUMBER         PATH '$.id' NULL ON ERROR,
                    id_jabatan      NUMBER         PATH '$.id_jabatan' NULL ON ERROR,
                    nama_jabatan    VARCHAR2(4000) PATH '$.nama_jabatan' NULL ON ERROR,
                    status_data     NUMBER         PATH '$.status_data' NULL ON ERROR
                )
            )
        )
        LOOP
            INSERT INTO BJKT_POSITIONS (
                ID, 
                POSITIONS_ID, 
                POSITIONS_NAME,
                STATUS_DATA
            ) VALUES (
                rec.id,
                rec.id_jabatan,
                rec.nama_jabatan,
                rec.status_data
            );
        END LOOP;

        R_STATUS    := 'SUCCESS';
        R_MESSAGE   := 'Get data positions successfully';

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := SQLERRM;

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MODE    := 'GET';
            L_LOG.IFACE_MESSAGE := SQLERRM;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

    END GET_POSITIONS;

    PROCEDURE GET_LEVELS (
        R_STATUS    OUT VARCHAR2,
        R_MESSAGE   OUT VARCHAR2
    ) 
    IS
        L_PATH                  VARCHAR2(1000) DEFAULT 'api/v3/get-list-all-tingkatan';
        L_TIMESTAMP             VARCHAR2(200);
        L_TOKEN                 VARCHAR2(4000);
        L_CLIENT_ID             VARCHAR2(1000);
        L_CLIENT_KEY            VARCHAR2(4000);
        L_SIGNATURE             VARCHAR2(4000);
        L_RAY_ID                VARCHAR2(20);
        L_HEADER                CLOB;
        L_BODY                  CLOB;
        L_RESULT_CLOB           CLOB;
        L_URL                   VARCHAR2(4000);
        L_WALLET_PATH           VARCHAR2(4000);
        L_WALLET_PASSWORD       VARCHAR2(4000);
        L_RESPONSE_CODE         NUMBER;
        -- L_RESPONSE_STATUS       BOOLEAN;
        -- L_RESPONSE_STATUS_CODE  VARCHAR2(200);

        L_LOG                   BJKT_API_LOG%ROWTYPE;
        L_LOG_ID                VARCHAR2 (100);
        L_LOG_STATUS            VARCHAR2 (100);
    BEGIN
        SELECT CLIENT_ID,
               CLIENT_KEY,
               URL,
               WALLET_PATH,
               WALLET_PASSWORD
          INTO L_CLIENT_ID,
               L_CLIENT_KEY,
               L_URL,
               L_WALLET_PATH,
               L_WALLET_PASSWORD
        FROM BJKT_FND_CREDENTIAL
        WHERE NAME = L_BANK_JKT
        FETCH FIRST 1 ROW ONLY;

        L_TIMESTAMP := TO_CHAR (SYSTIMESTAMP, 'rrrr-mm-dd') 
                        || 'T'
                        || TO_CHAR (SYSTIMESTAMP, 'hh24:mi:ssTZR');

        L_TOKEN     := GET_ACCESS_TOKEN(L_TIMESTAMP);
        L_RAY_ID    := BJKT_JAVA_PKG.GET_RAY_ID();

        L_SIGNATURE :=
            BJKT_JAVA_PKG.SNAP_SIGNATURE_SHA512HMAC (
                P_CLIENT_SECRET   => L_CLIENT_KEY,
                P_HTTP_METHOD     => 'GET',
                P_URL_X           => '/service-sso/' || L_PATH,
                P_TOKEN           => L_TOKEN,
                P_REQUEST_BODY    => NULL,
                P_TIMESTAMP       => L_TIMESTAMP
            );

        -- DBMS_OUTPUT.PUT_LINE('P_CLIENT_SECRET : ' || L_CLIENT_KEY);
        -- DBMS_OUTPUT.PUT_LINE('P_HTTP_METHOD   : ' || 'GET');
        -- DBMS_OUTPUT.PUT_LINE('P_URL_X         : ' || '/' || L_PATH);
        -- DBMS_OUTPUT.PUT_LINE('P_TOKEN         : ' || L_TOKEN);
        -- DBMS_OUTPUT.PUT_LINE('P_REQUEST_BODY  : ' || NULL);
        -- DBMS_OUTPUT.PUT_LINE('P_TIMESTAMP     : ' || L_TIMESTAMP);

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;

        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).NAME     := 'Content-Type';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE    := 'application/json';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).NAME     := 'Authorization';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE    := 'Bearer ' || L_TOKEN;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).NAME     := 'X-TIMESTAMP';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE    := L_TIMESTAMP;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).NAME     := 'X-CHANNEL-KEY';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE    := L_CLIENT_ID;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).NAME     := 'X-SIGNATURE';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE    := L_SIGNATURE;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).NAME     := 'X-RAY-ID';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).VALUE    := L_RAY_ID;

        FOR I IN 1 .. APEX_WEB_SERVICE.G_REQUEST_HEADERS.COUNT
        LOOP
            L_HEADER := L_HEADER
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).NAME
                        || ': '
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).VALUE
                        || CHR (10);
        END LOOP;

        L_RESULT_CLOB :=
            APEX_WEB_SERVICE.MAKE_REST_REQUEST (
                P_URL           => L_URL || L_API_GROUP || L_PATH,
                P_HTTP_METHOD   => 'GET'
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
            );

        L_RESPONSE_CODE := APEX_WEB_SERVICE.G_STATUS_CODE;

        IF L_RESPONSE_CODE <> 200
        THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MESSAGE := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;
            L_LOG.IFACE_MODE    := 'GET';

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

            RETURN;
        END IF;

        APEX_JSON.PARSE (L_RESULT_CLOB);

        -- L_RESPONSE_STATUS       := APEX_JSON.GET_BOOLEAN (P_PATH => 'status');
        -- L_RESPONSE_STATUS_CODE  := APEX_JSON.GET_VARCHAR2 (P_PATH => 'statusCode');

        -- Delete semua data lama sebelum insert
        DELETE FROM BJKT_LEVELS;

        -- Insert dari response JSON menggunakan JSON_TABLE
        FOR rec IN (
            SELECT *
            FROM JSON_TABLE(
                L_RESULT_CLOB,
                '$.result[*]'
                COLUMNS (
                    id              NUMBER         PATH '$.id' NULL ON ERROR,
                    id_tingkatan    NUMBER         PATH '$.id_tingkatan' NULL ON ERROR,
                    nama_tingkatan  VARCHAR2(4000) PATH '$.nama_tingkatan' NULL ON ERROR,
                    status_data     NUMBER         PATH '$.status_data' NULL ON ERROR
                )
            )
        )
        LOOP
            INSERT INTO BJKT_LEVELS (
                ID, 
                LEVEL_ID, 
                LEVEL_NAME,
                STATUS_DATA
            ) VALUES (
                rec.id,
                rec.id_tingkatan,
                rec.nama_tingkatan,
                rec.status_data
            );
        END LOOP;

        R_STATUS    := 'SUCCESS';
        R_MESSAGE   := 'Get data positions successfully';

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := SQLERRM;

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MODE    := 'GET';
            L_LOG.IFACE_MESSAGE := SQLERRM;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

    END GET_LEVELS;

    PROCEDURE GET_WORK_UNITS (
        R_STATUS    OUT VARCHAR2,
        R_MESSAGE   OUT VARCHAR2
    ) 
    IS
        L_PATH                  VARCHAR2(1000) DEFAULT 'api/v3/get-list-all-unit-kerja';
        L_TIMESTAMP             VARCHAR2(200);
        L_TOKEN                 VARCHAR2(4000);
        L_CLIENT_ID             VARCHAR2(1000);
        L_CLIENT_KEY            VARCHAR2(4000);
        L_SIGNATURE             VARCHAR2(4000);
        L_RAY_ID                VARCHAR2(20);
        L_HEADER                CLOB;
        L_BODY                  CLOB;
        L_RESULT_CLOB           CLOB;
        L_URL                   VARCHAR2(4000);
        L_WALLET_PATH           VARCHAR2(4000);
        L_WALLET_PASSWORD       VARCHAR2(4000);
        L_RESPONSE_CODE         NUMBER;
        -- L_RESPONSE_STATUS       BOOLEAN;
        -- L_RESPONSE_STATUS_CODE  VARCHAR2(200);

        L_LOG                   BJKT_API_LOG%ROWTYPE;
        L_LOG_ID                VARCHAR2 (100);
        L_LOG_STATUS            VARCHAR2 (100);
    BEGIN
        SELECT CLIENT_ID,
               CLIENT_KEY,
               URL,
               WALLET_PATH,
               WALLET_PASSWORD
          INTO L_CLIENT_ID,
               L_CLIENT_KEY,
               L_URL,
               L_WALLET_PATH,
               L_WALLET_PASSWORD
        FROM BJKT_FND_CREDENTIAL
        WHERE NAME = L_BANK_JKT
        FETCH FIRST 1 ROW ONLY;

        L_TIMESTAMP := TO_CHAR (SYSTIMESTAMP, 'rrrr-mm-dd') 
                        || 'T'
                        || TO_CHAR (SYSTIMESTAMP, 'hh24:mi:ssTZR');

        L_TOKEN     := GET_ACCESS_TOKEN(L_TIMESTAMP);
        L_RAY_ID    := BJKT_JAVA_PKG.GET_RAY_ID();

        L_SIGNATURE :=
            BJKT_JAVA_PKG.SNAP_SIGNATURE_SHA512HMAC (
                P_CLIENT_SECRET   => L_CLIENT_KEY,
                P_HTTP_METHOD     => 'GET',
                P_URL_X           => '/service-sso/' || L_PATH,
                P_TOKEN           => L_TOKEN,
                P_REQUEST_BODY    => NULL,
                P_TIMESTAMP       => L_TIMESTAMP
            );

        -- DBMS_OUTPUT.PUT_LINE('P_CLIENT_SECRET : ' || L_CLIENT_KEY);
        -- DBMS_OUTPUT.PUT_LINE('P_HTTP_METHOD   : ' || 'GET');
        -- DBMS_OUTPUT.PUT_LINE('P_URL_X         : ' || '/' || L_PATH);
        -- DBMS_OUTPUT.PUT_LINE('P_TOKEN         : ' || L_TOKEN);
        -- DBMS_OUTPUT.PUT_LINE('P_REQUEST_BODY  : ' || NULL);
        -- DBMS_OUTPUT.PUT_LINE('P_TIMESTAMP     : ' || L_TIMESTAMP);

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;

        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).NAME     := 'Content-Type';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE    := 'application/json';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).NAME     := 'Authorization';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE    := 'Bearer ' || L_TOKEN;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).NAME     := 'X-TIMESTAMP';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE    := L_TIMESTAMP;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).NAME     := 'X-CHANNEL-KEY';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE    := L_CLIENT_ID;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).NAME     := 'X-SIGNATURE';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE    := L_SIGNATURE;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).NAME     := 'X-RAY-ID';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).VALUE    := L_RAY_ID;

        FOR I IN 1 .. APEX_WEB_SERVICE.G_REQUEST_HEADERS.COUNT
        LOOP
            L_HEADER := L_HEADER
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).NAME
                        || ': '
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).VALUE
                        || CHR (10);
        END LOOP;

        L_RESULT_CLOB :=
            APEX_WEB_SERVICE.MAKE_REST_REQUEST (
                P_URL           => L_URL || L_API_GROUP || L_PATH,
                P_HTTP_METHOD   => 'GET'
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
            );

        APEX_JSON.PARSE (L_RESULT_CLOB);

        IF L_RESPONSE_CODE <> 200
        THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MESSAGE := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;
            L_LOG.IFACE_MODE    := 'GET';

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

            RETURN;
        END IF;

        -- L_RESPONSE_STATUS       := APEX_JSON.GET_BOOLEAN (P_PATH => 'status');
        -- L_RESPONSE_STATUS_CODE  := APEX_JSON.GET_VARCHAR2 (P_PATH => 'statusCode');

        -- Delete semua data lama sebelum insert
        DELETE FROM BJKT_WORK_UNITS;

        -- Insert dari response JSON menggunakan JSON_TABLE
        FOR rec IN (
            SELECT *
            FROM JSON_TABLE(
                L_RESULT_CLOB,
                '$.result[*]'
                COLUMNS (
                    id                  NUMBER         PATH '$.id' NULL ON ERROR,
                    id_unit_kerja       NUMBER         PATH '$.id_unit_kerja' NULL ON ERROR,
                    nama_unit_kerja     VARCHAR2(4000) PATH '$.nama_unit_kerja' NULL ON ERROR,
                    kode_branch_induk   VARCHAR2(200)  PATH '$.kode_branch_induk' NULL ON ERROR,
                    kode_branch         VARCHAR2(200)  PATH '$.kode_branch' NULL ON ERROR,
                    kategori_unit_kerja VARCHAR2(200)  PATH '$.kategori_unit_kerja' NULL ON ERROR,
                    status_data         NUMBER         PATH '$.status_data' NULL ON ERROR
                )
            )
        )
        LOOP
            INSERT INTO BJKT_WORK_UNITS (
                ID, 
                WORK_UNIT_ID, 
                WORK_UNIT_NAME,
                PARENT_BRANCH_CODE,
                BRANCH_CODE,
                WORK_UNIT_CATEGORY,
                STATUS_DATA
            ) VALUES (
                rec.id,
                rec.id_unit_kerja,
                rec.nama_unit_kerja,
                rec.kode_branch_induk,
                rec.kode_branch,
                rec.kategori_unit_kerja,
                rec.status_data
            );
        END LOOP;

        R_STATUS    := 'SUCCESS';
        R_MESSAGE   := 'Get data work units successfully';

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := SQLERRM;

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MODE    := 'GET';
            L_LOG.IFACE_MESSAGE := SQLERRM;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

    END GET_WORK_UNITS;

    PROCEDURE GET_MODEL_WORK_UNITS (
        R_STATUS    OUT VARCHAR2,
        R_MESSAGE   OUT VARCHAR2
    ) 
    IS
        L_PATH                  VARCHAR2(1000) DEFAULT 'api/v3/get-list-all-model-unit-kerja';
        L_TIMESTAMP             VARCHAR2(200);
        L_TOKEN                 VARCHAR2(4000);
        L_CLIENT_ID             VARCHAR2(1000);
        L_CLIENT_KEY            VARCHAR2(4000);
        L_SIGNATURE             VARCHAR2(4000);
        L_RAY_ID                VARCHAR2(20);
        L_HEADER                CLOB;
        L_BODY                  CLOB;
        L_RESULT_CLOB           CLOB;
        L_URL                   VARCHAR2(4000);
        L_WALLET_PATH           VARCHAR2(4000);
        L_WALLET_PASSWORD       VARCHAR2(4000);
        L_RESPONSE_CODE         NUMBER;
        -- L_RESPONSE_STATUS       BOOLEAN;
        -- L_RESPONSE_STATUS_CODE  VARCHAR2(200);

        L_LOG                   BJKT_API_LOG%ROWTYPE;
        L_LOG_ID                VARCHAR2 (100);
        L_LOG_STATUS            VARCHAR2 (100);
    BEGIN
        SELECT CLIENT_ID,
               CLIENT_KEY,
               URL,
               WALLET_PATH,
               WALLET_PASSWORD
          INTO L_CLIENT_ID,
               L_CLIENT_KEY,
               L_URL,
               L_WALLET_PATH,
               L_WALLET_PASSWORD
        FROM BJKT_FND_CREDENTIAL
        WHERE NAME = L_BANK_JKT
        FETCH FIRST 1 ROW ONLY;

        L_TIMESTAMP := TO_CHAR (SYSTIMESTAMP, 'rrrr-mm-dd') 
                        || 'T'
                        || TO_CHAR (SYSTIMESTAMP, 'hh24:mi:ssTZR');

        L_TOKEN     := GET_ACCESS_TOKEN(L_TIMESTAMP);
        L_RAY_ID    := BJKT_JAVA_PKG.GET_RAY_ID();

        L_SIGNATURE :=
            BJKT_JAVA_PKG.SNAP_SIGNATURE_SHA512HMAC (
                P_CLIENT_SECRET   => L_CLIENT_KEY,
                P_HTTP_METHOD     => 'GET',
                P_URL_X           => '/service-sso/' || L_PATH,
                P_TOKEN           => L_TOKEN,
                P_REQUEST_BODY    => NULL,
                P_TIMESTAMP       => L_TIMESTAMP
            );

        -- DBMS_OUTPUT.PUT_LINE('P_CLIENT_SECRET : ' || L_CLIENT_KEY);
        -- DBMS_OUTPUT.PUT_LINE('P_HTTP_METHOD   : ' || 'GET');
        -- DBMS_OUTPUT.PUT_LINE('P_URL_X         : ' || '/' || L_PATH);
        -- DBMS_OUTPUT.PUT_LINE('P_TOKEN         : ' || L_TOKEN);
        -- DBMS_OUTPUT.PUT_LINE('P_REQUEST_BODY  : ' || NULL);
        -- DBMS_OUTPUT.PUT_LINE('P_TIMESTAMP     : ' || L_TIMESTAMP);

        APEX_WEB_SERVICE.G_REQUEST_HEADERS.DELETE;

        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).NAME     := 'Content-Type';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE    := 'application/json';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).NAME     := 'Authorization';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE    := 'Bearer ' || L_TOKEN;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).NAME     := 'X-TIMESTAMP';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE    := L_TIMESTAMP;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).NAME     := 'X-CHANNEL-KEY';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE    := L_CLIENT_ID;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).NAME     := 'X-SIGNATURE';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE    := L_SIGNATURE;
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).NAME     := 'X-RAY-ID';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS (6).VALUE    := L_RAY_ID;

        FOR I IN 1 .. APEX_WEB_SERVICE.G_REQUEST_HEADERS.COUNT
        LOOP
            L_HEADER := L_HEADER
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).NAME
                        || ': '
                        || APEX_WEB_SERVICE.G_REQUEST_HEADERS (I).VALUE
                        || CHR (10);
        END LOOP;

        L_RESULT_CLOB :=
            APEX_WEB_SERVICE.MAKE_REST_REQUEST (
                P_URL           => L_URL || L_API_GROUP || L_PATH,
                P_HTTP_METHOD   => 'GET'
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
            );

        APEX_JSON.PARSE (L_RESULT_CLOB);

        IF L_RESPONSE_CODE <> 200
        THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MESSAGE := 'ERROR CODE : ' || TO_CHAR(L_RESPONSE_CODE);

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;
            L_LOG.IFACE_MODE    := 'GET';

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

            RETURN;
        END IF;

        -- L_RESPONSE_STATUS       := APEX_JSON.GET_BOOLEAN (P_PATH => 'status');
        -- L_RESPONSE_STATUS_CODE  := APEX_JSON.GET_VARCHAR2 (P_PATH => 'statusCode');

        -- Delete semua data lama sebelum insert
        DELETE FROM BJKT_MODEL_WORK_UNITS;

        -- Insert dari response JSON menggunakan JSON_TABLE
        FOR rec IN (
            SELECT *
            FROM JSON_TABLE(
                L_RESULT_CLOB,
                '$.result[*]'
                COLUMNS (
                    id                      NUMBER         PATH '$.id' NULL ON ERROR,
                    id_model                NUMBER         PATH '$.id_model' NULL ON ERROR,
                    nama_model_unit_kerja   VARCHAR2(4000) PATH '$.nama_model_unit_kerja' NULL ON ERROR,
                    status_data             NUMBER         PATH '$.status_data' NULL ON ERROR
                )
            )
        )
        LOOP
            INSERT INTO BJKT_MODEL_WORK_UNITS (
                ID, 
                MODEL_ID, 
                MODEL_NAME,
                STATUS_DATA
            ) VALUES (
                rec.id,
                rec.id_model,
                rec.nama_model_unit_kerja,
                rec.status_data
            );
        END LOOP;

        R_STATUS    := 'SUCCESS';
        R_MESSAGE   := 'Get data work units successfully';

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            R_STATUS            := 'ERROR';
            R_MESSAGE           := SQLERRM;

            L_LOG.URL           := L_URL || L_API_GROUP || L_PATH;
            L_LOG.NAME          := L_BANK_JKT;
            L_LOG.RAY_ID        := L_RAY_ID;
            L_LOG.ACCESS_TOKEN  := L_TOKEN;
            L_LOG.REQUEST       := L_BODY;
            L_LOG.RESPONSE      := L_RESULT_CLOB;

            L_LOG.CONTENT_TYPE  := APEX_WEB_SERVICE.G_REQUEST_HEADERS (1).VALUE;
            L_LOG.AUTHORIZATION := APEX_WEB_SERVICE.G_REQUEST_HEADERS (2).VALUE;
            L_LOG.TIME_STAMP    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (3).VALUE;
            L_LOG.CHANNEL_ID    := APEX_WEB_SERVICE.G_REQUEST_HEADERS (4).VALUE;
            L_LOG.SIGNATURE     := APEX_WEB_SERVICE.G_REQUEST_HEADERS (5).VALUE;
            L_LOG.HEADER        := L_HEADER;

            L_LOG.IFACE_STATUS  := 'ERROR';
            L_LOG.IFACE_MODE    := 'GET';
            L_LOG.IFACE_MESSAGE := SQLERRM;

            IFACE_LOG (
                P_LOG      => L_LOG,
                X_LOG_ID   => L_LOG_ID,
                X_STATUS   => L_LOG_STATUS
            );

    END GET_MODEL_WORK_UNITS;


end "BJKT_SSO_INTEGRATIONS_PKG";
/