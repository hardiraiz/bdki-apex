-- DROP JAVA SOURCE DEV."BJKTSignSHA512HMAC";

SET DEFINE OFF;

CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED DEV."BJKTSignSHA512HMAC"
as import java.nio.charset.StandardCharsets;
    import java.security.MessageDigest;
    import java.security.NoSuchAlgorithmException;
    import java.security.InvalidKeyException;
    import javax.crypto.Mac;
    import javax.crypto.spec.SecretKeySpec;
    import java.util.Base64;

    public class BJKTSignSHA512HMAC {

        public static String sign(String v_client_secret, String v_http_method, String v_url_x, String v_token, String v_request_body, String v_timestamp) throws Exception {

            String minifyBody;

            // Check if the body is empty (sama seperti Go: len(bodyRequest) == 0)
            if (v_request_body == null || v_request_body.length() == 0) {
                minifyBody = "";
            } else {
                // Minify JSON (sama seperti Go: json.Compact)
                minifyBody = minifyJson(v_request_body);
            }

            // hashMinifyBody := strings.ToLower(helpers.HashSHA256(minifyBody))
            String hashMinifyBody = hash256(minifyBody);

            // result = method + ":" + originalUrl + ":" + token + ":" + hashMinifyBody + ":" + timeStamp
            String stringToSign = v_http_method
                + ":" + v_url_x
                + ":" + v_token
                + ":" + hashMinifyBody
                + ":" + v_timestamp;

            // hmac.New(sha512.New) + base64.StdEncoding.EncodeToString
            return Base64.getEncoder().encodeToString(
                calculateHMACSHA512(stringToSign, v_client_secret)
            );
        }

        // Terjemahan json.Compact dari Go
        private static String minifyJson(String json) {
            StringBuilder sb = new StringBuilder();
            boolean inString = false;
            for (int i = 0; i < json.length(); i++) {
                char c = json.charAt(i);
                if (c == '"' && (i == 0 || json.charAt(i - 1) != '\\')) {
                    inString = !inString;
                }
                if (!inString && (c == ' ' || c == '\n' || c == '\r' || c == '\t')) {
                    continue;
                }
                sb.append(c);
            }
            return sb.toString();
        }

        // strings.ToLower(helpers.HashSHA256(input))
        public static String hash256(String input) throws NoSuchAlgorithmException {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexStr = new StringBuilder();
            for (int i = 0; i < hash.length; i++) {
                String hex = Integer.toHexString(0xff & hash[i]);
                if (hex.length() == 1) hexStr.append('0');
                hexStr.append(hex);
            }
            return hexStr.toString(); // sudah lowercase
        }

        // hmac.New(sha512.New, channelSecretByte) + h.Write + h.Sum
        private static byte[] calculateHMACSHA512(String data, String key) throws NoSuchAlgorithmException, InvalidKeyException {
            SecretKeySpec secretKeySpec = new SecretKeySpec(
                key.getBytes(StandardCharsets.UTF_8),
                "HmacSHA512"
            );
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(secretKeySpec);
            return mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        }
    }
/