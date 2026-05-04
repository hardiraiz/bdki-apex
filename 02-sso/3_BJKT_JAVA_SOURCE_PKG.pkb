CREATE OR REPLACE PACKAGE BODY DEV.BJKT_JAVA_PKG
AS
    FUNCTION SNAP_TOKEN (
        P_PRIVATE_KEY      IN VARCHAR2,
        P_STRING_TO_SIGN   IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSnapTokenJava.sign(java.lang.String, java.lang.String) return java.lang.String' ;

    FUNCTION SNAP_TOKEN_64 (
        P_PRIVATE_KEY      IN VARCHAR2,
        P_STRING_TO_SIGN   IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSnapTokenJava64.sign(java.lang.String, java.lang.String) return java.lang.String' ;

    FUNCTION SNAP_SIGNATURE (
        P_CLIENT_SECRET   IN VARCHAR2,
        P_HTTP_METHOD     IN VARCHAR2,
        P_URL_X           IN VARCHAR2,
        P_TOKEN           IN VARCHAR2,
        P_TIMESTAMP       IN VARCHAR2,
        P_REQUEST_BODY    IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSnapSignatureJava.sign(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String' ;

    FUNCTION SNAP_SIGNATURE64 (
        P_CLIENT_SECRET   IN VARCHAR2,
        P_HTTP_METHOD     IN VARCHAR2,
        P_URL_X           IN VARCHAR2,
        P_TOKEN           IN VARCHAR2,
        P_TIMESTAMP       IN VARCHAR2,
        P_REQUEST_BODY    IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSnapSignatureJava64.sign(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String' ;

    FUNCTION HASH256 (
        P_INPUT IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSnapSignatureJava.hash256(java.lang.String) return java.lang.String' ;

    FUNCTION HASH256_HMAC (
        P_INPUT IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSignSHA512HMACStripChar.hash256(java.lang.String) return java.lang.String' ;

    FUNCTION SNAP_SIGNATURE_SHA512HMAC (
        P_CLIENT_SECRET   IN VARCHAR2,
        P_HTTP_METHOD     IN VARCHAR2,
        P_URL_X           IN VARCHAR2,
        P_TOKEN           IN VARCHAR2,
        P_REQUEST_BODY    IN VARCHAR2,
        P_TIMESTAMP       IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSignSHA512HMAC.sign(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String' ;

    FUNCTION SNAP_SIGNATURE_SHA512HMAC_STC (
        P_CLIENT_SECRET   IN VARCHAR2,
        P_HTTP_METHOD     IN VARCHAR2,
        P_URL_X           IN VARCHAR2,
        P_TOKEN           IN VARCHAR2,
        P_REQUEST_BODY    IN VARCHAR2,
        P_TIMESTAMP       IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSignSHA512HMACStripChar.sign(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String' ;

    FUNCTION SNAP_SIGNATURE_SHA512HMAC_PAN (
        P_CLIENT_SECRET   IN VARCHAR2,
        P_HTTP_METHOD     IN VARCHAR2,
        P_URL_X           IN VARCHAR2,
        P_TOKEN           IN VARCHAR2,
        P_REQUEST_BODY    IN VARCHAR2,
        P_TIMESTAMP       IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTSignSHA512HMACStripCharPan.sign(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String' ;

    FUNCTION HEX_ENCODE_256_REQUEST_BODY (
        P_REQUEST_BODY IN VARCHAR2
    ) RETURN VARCHAR2
    AS
        LANGUAGE JAVA
        NAME 'BJKTHexEncode256RequestBody.sign(java.lang.String) return java.lang.String' ;

    FUNCTION GET_RAY_ID (
        P_LENGTH IN NUMBER DEFAULT 16
    ) RETURN VARCHAR2
    IS
        l_chars   VARCHAR2(62) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        l_result  VARCHAR2(4000);
    BEGIN
        FOR i IN 1..p_length LOOP
            l_result := l_result || SUBSTR(l_chars, TRUNC(DBMS_RANDOM.VALUE(1, LENGTH(l_chars)+1)), 1);
        END LOOP;

        RETURN l_result;
    END;

END BJKT_JAVA_PKG;
/