/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package resource;


import com.google.auth.oauth2.GoogleCredentials;
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
import java.util.Collections;
import java.util.logging.Level;
import java.util.logging.Logger;

@Path("/notifications")
public class NotificationResource {

    private static final Logger LOG =
            Logger.getLogger(NotificationResource.class.getName());

    private static final String PROJECT_ID = "gomart-8a5ad";
    private static final String FCM_URL    =
            "https://fcm.googleapis.com/v1/projects/"
                    + PROJECT_ID + "/messages:send";
    private static final String FCM_SCOPE  =
            "https://www.googleapis.com/auth/firebase.messaging";

    // ── Health check ──────────────────────────────────────────────
    @GET
    @Path("/health")
    @Produces(MediaType.APPLICATION_JSON)
    public Response health() {
        return Response.ok(
                "{\"status\":\"ok\","
                + "\"service\":\"GoMart Notification API\"}")
                .build();
    }

    // ── Send notification ─────────────────────────────────────────
    @POST
    @Path("/send")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response sendNotification(NotificationRequest req) {

        LOG.info("Request: " + req);

        if (req == null) {
            return Response
                    .status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"Request is empty\"}")
                    .build();
        }
        if (req.getToken() == null
                || req.getToken().isEmpty()) {
            return Response
                    .status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"Token is required\"}")
                    .build();
        }
        if (req.getTitle() == null
                || req.getTitle().isEmpty()) {
            return Response
                    .status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"Title is required\"}")
                    .build();
        }
        if (req.getMessage() == null
                || req.getMessage().isEmpty()) {
            return Response
                    .status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"Message is required\"}")
                    .build();
        }

        try {
            int code = sendFcmMessage(
                    req.getToken(),
                    req.getTitle(),
                    req.getMessage(),
                    req.getOrderId(),
                    req.getType()
            );

            if (code == 200) {
                LOG.info("✅ FCM sent successfully");
                return Response.ok(
                        "{\"success\":true,"
                        + "\"message\":"
                        + "\"Notification sent successfully\"}")
                        .build();
            } else {
                LOG.warning("FCM failed: " + code);
                return Response.status(500)
                        .entity("{\"error\":\"FCM code: "
                                + code + "\"}")
                        .build();
            }

        } catch (Exception e) {
            LOG.log(Level.SEVERE, "FCM error", e);
            return Response.status(500)
                    .entity("{\"error\":\""
                            + e.getMessage() + "\"}")
                    .build();
        }
    }

    // ── Send FCM HTTP request ─────────────────────────────────────
    private int sendFcmMessage(String token, String title,
                                String message, String orderId,
                                String type) throws Exception {

        String accessToken = getAccessToken();
        String body = buildFcmJson(
                token, title, message, orderId, type);

        LOG.info("FCM Body: " + body);

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
            byte[] input = body.getBytes(
                    StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
            os.flush();
        }

        int responseCode = conn.getResponseCode();

        // Log response body
        try {
            InputStream is = responseCode == 200
                    ? conn.getInputStream()
                    : conn.getErrorStream();
            if (is != null) {
                BufferedReader br = new BufferedReader(
                        new InputStreamReader(is,
                                StandardCharsets.UTF_8));
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line);
                }
                LOG.info("FCM Response: " + sb);
            }
        } catch (Exception e) {
            LOG.warning("Response read error: "
                    + e.getMessage());
        }

        return responseCode;
    }

    // ── Build FCM JSON ────────────────────────────────────────────
    private String buildFcmJson(String token, String title,
                                 String message, String orderId,
                                 String type) {
        return "{"
            + "\"message\": {"
            + "  \"token\": \"" + escapeJson(token) + "\","
            + "  \"notification\": {"
            + "    \"title\": \"" + escapeJson(title) + "\","
            + "    \"body\":  \"" + escapeJson(message) + "\""
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

    // ── Get OAuth2 access token ───────────────────────────────────
    private String getAccessToken() throws Exception {
        InputStream serviceAccount =
                getClass().getClassLoader()
                        .getResourceAsStream(
                                "gomart-service-account.json");

        if (serviceAccount == null) {
            throw new Exception(
                    "gomart-service-account.json not found! "
                    + "Place it in WEB-INF/classes/");
        }

        GoogleCredentials credentials =
                GoogleCredentials
                        .fromStream(serviceAccount)
                        .createScoped(Collections.singletonList(
                                FCM_SCOPE));

        credentials.refreshIfExpired();
        return credentials.getAccessToken().getTokenValue();
    }

    // ── Escape JSON ───────────────────────────────────────────────
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