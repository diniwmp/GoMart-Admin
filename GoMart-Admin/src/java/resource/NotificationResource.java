package resource;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;

@Path("/notifications")
public class NotificationResource {

    private static final Logger LOG =
            Logger.getLogger(
                    NotificationResource.class.getName());

    private static final String PROJECT_ID = "gomart-e6709";

    private static final String FCM_URL =
            "https://fcm.googleapis.com/v1/projects/"
            + PROJECT_ID + "/messages:send";

    private static final String FCM_SCOPE =
            "https://www.googleapis.com/auth/firebase.messaging";

    @GET
    @Path("/health")
    @Produces(MediaType.APPLICATION_JSON)
    public Response health() {
        return Response.ok(
                "{\"status\":\"ok\","
                + "\"service\":\"GoMart Notification API\"}")
                .build();
    }

    //  Send notification 
    @POST
    @Path("/send")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response sendNotification(NotificationRequest req) {

        LOG.info("Request received: " + req);

        if (req == null || req.getToken() == null
                || req.getToken().isEmpty()) {
            return Response
                    .status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"Token required\"}")
                    .build();
        }

        try {
            int code = sendFcmMessage(
                    req.getToken(),
                    req.getTitle(),
                    req.getMessage(),
                    req.getOrderId(),
                    req.getType());

            if (code == 200) {
                LOG.info("FCM sent successfully");
                return Response.ok(
                        "{\"success\":true}").build();
            } else {
                return Response.status(500)
                        .entity("{\"error\":\"FCM code: "
                                + code + "\"}")
                        .build();
            }

        } catch (Exception e) {
            if ("FCM_SKIP".equals(e.getMessage())) {
                LOG.warning("FCM skipped — no service account."
                        + " In-app notification saved.");
                return Response.ok(
                        "{\"success\":true,"
                        + "\"note\":\"in-app only\"}")
                        .build();
            }
            LOG.log(Level.SEVERE, "FCM error", e);
            return Response.status(500)
                    .entity("{\"error\":\""
                            + e.getMessage() + "\"}")
                    .build();
        }
    }

    // Send FCM via HTTP v1 API 
    private int sendFcmMessage(String token,
                                String title,
                                String message,
                                String orderId,
                                String type) throws Exception {

        String accessToken = getAccessToken();
        String body = buildFcmJson(
                token, title, message, orderId, type);

        LOG.info("Sending FCM to token: "
                + token.substring(0, 20) + "...");

        URL url = new URL(FCM_URL);
        HttpURLConnection conn =
                (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization",
                "Bearer " + accessToken);
        conn.setRequestProperty("Content-Type",
                "application/json; UTF-8");
        conn.setDoOutput(true);
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(15000);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = body
                    .getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
            os.flush();
        }

        int responseCode = conn.getResponseCode();
        LOG.info("FCM Response Code: " + responseCode);

        try {
            InputStream is = responseCode == 200
                    ? conn.getInputStream()
                    : conn.getErrorStream();
            LOG.info("FCM Response Body: "
                    + readStream(is));
        } catch (Exception e) {
            LOG.warning("Could not read response: "
                    + e.getMessage());
        }

        return responseCode;
    }

    //  Build FCM JSON 
    private String buildFcmJson(String token,
                                 String title,
                                 String message,
                                 String orderId,
                                 String type) {
        return "{"
                + "\"message\": {"
                + "  \"token\": \""
                +       escapeJson(token) + "\","
                + "  \"notification\": {"
                + "    \"title\": \""
                +       escapeJson(title) + "\","
                + "    \"body\":  \""
                +       escapeJson(message) + "\""
                + "  },"
                + "  \"data\": {"
                + "    \"orderId\": \""
                +       escapeJson(orderId != null
                                ? orderId : "") + "\","
                + "    \"type\": \""
                +       escapeJson(type != null
                                ? type : "ORDER") + "\","
                + "    \"title\": \""
                +       escapeJson(title) + "\","
                + "    \"message\": \""
                +       escapeJson(message) + "\""
                + "  },"
                + "  \"android\": {"
                + "    \"priority\": \"high\","
                + "    \"notification\": {"
                + "      \"sound\": \"default\","
                + "      \"channel_id\": \"gomart_orders\""
                + "    }"
                + "  }"
                + "}"
                + "}";
    }

    //  Get OAuth2 token 
    private String getAccessToken() throws Exception {

        InputStream serviceAccount =
                getClass().getClassLoader()
                        .getResourceAsStream(
                                "gomart-service-account.json");

        if (serviceAccount == null) {
            serviceAccount = getClass()
                    .getResourceAsStream(
                            "/gomart-service-account.json");
        }

        if (serviceAccount == null) {
            LOG.warning("Service account not found — skipping");
            throw new Exception("FCM_SKIP");
        }

        String json = readStream(serviceAccount);

        String privateKeyStr =
                extractJson(json, "private_key");
        String clientEmail =
                extractJson(json, "client_email");

        if (privateKeyStr == null || clientEmail == null) {
            throw new Exception(
                    "Invalid service account JSON");
        }

        String jwt = buildJwt(privateKeyStr, clientEmail);
        return exchangeJwtForToken(jwt);
    }

    //  Build JWT 
    private String buildJwt(String privateKeyPem,
                              String clientEmail)
            throws Exception {

        // Clean PEM key
        String cleanKey = privateKeyPem
                .replace("-----BEGIN PRIVATE KEY-----", "")
                .replace("-----END PRIVATE KEY-----", "")
                .replaceAll("\\\\n", "")
                .replaceAll("\n", "")
                .replaceAll("\r", "")
                .trim();

        //  Decode using Java 8 Base64
        byte[] keyBytes = java.util.Base64.getDecoder()
                .decode(cleanKey);

        java.security.spec.PKCS8EncodedKeySpec keySpec =
                new java.security.spec.PKCS8EncodedKeySpec(
                        keyBytes);
        java.security.KeyFactory kf =
                java.security.KeyFactory.getInstance("RSA");
        java.security.PrivateKey privateKey =
                kf.generatePrivate(keySpec);

        long now = System.currentTimeMillis() / 1000;

        String header = base64UrlEncode(
                ("{\"alg\":\"RS256\",\"typ\":\"JWT\"}")
                        .getBytes(StandardCharsets.UTF_8));

        String payload = base64UrlEncode(
                ("{\"iss\":\"" + clientEmail + "\","
                + "\"scope\":\"" + FCM_SCOPE + "\","
                + "\"aud\":"
                + "\"https://oauth2.googleapis.com/token\","
                + "\"exp\":" + (now + 3600) + ","
                + "\"iat\":" + now + "}")
                        .getBytes(StandardCharsets.UTF_8));

        String signingInput = header + "." + payload;

        java.security.Signature sig =
                java.security.Signature
                        .getInstance("SHA256withRSA");
        sig.initSign(privateKey);
        sig.update(signingInput
                .getBytes(StandardCharsets.UTF_8));
        byte[] signature = sig.sign();

        return signingInput + "."
                + base64UrlEncode(signature);
    }

    //  Exchange JWT for access token 
    private String exchangeJwtForToken(String jwt)
            throws Exception {

        String params = "grant_type="
                + java.net.URLEncoder.encode(
                        "urn:ietf:params:oauth:"
                        + "grant-type:jwt-bearer", "UTF-8")
                + "&assertion="
                + java.net.URLEncoder.encode(jwt, "UTF-8");

        URL url = new URL(
                "https://oauth2.googleapis.com/token");
        HttpURLConnection conn =
                (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type",
                "application/x-www-form-urlencoded");
        conn.setDoOutput(true);
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(15000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes(StandardCharsets.UTF_8));
            os.flush();
        }

        int code = conn.getResponseCode();

        InputStream is = code == 200
                ? conn.getInputStream()
                : conn.getErrorStream();

        String response = readStream(is);
        LOG.info("Token response code: " + code);

        if (code != 200) {
            throw new Exception(
                    "Token exchange failed: " + response);
        }

        String token = extractJson(response, "access_token");
        if (token == null) {
            throw new Exception(
                    "No access_token in response");
        }

        LOG.info("OAuth2 token obtained");
        return token;
    }

    private String readStream(InputStream is) throws Exception {
        if (is == null) return "";
        BufferedReader br = new BufferedReader(
                new InputStreamReader(
                        is, StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            sb.append(line);
        }
        br.close();
        return sb.toString();
    }

    private String base64UrlEncode(byte[] data) {
        return java.util.Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(data);
    }

    private String extractJson(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return null;

        int colon = json.indexOf(":", idx);
        if (colon < 0) return null;

        int start = json.indexOf("\"", colon) + 1;
        if (start <= 0) return null;

        StringBuilder sb = new StringBuilder();
        int i = start;
        while (i < json.length()) {
            char c = json.charAt(i);
            if (c == '\\' && i + 1 < json.length()) {
                char next = json.charAt(i + 1);
                if      (next == 'n')  sb.append('\n');
                else if (next == '"')  sb.append('"');
                else if (next == '\\') sb.append('\\');
                else                   sb.append(next);
                i += 2;
            } else if (c == '"') {
                break;
            } else {
                sb.append(c);
                i++;
            }
        }
        return sb.toString();
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}