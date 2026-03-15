/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package resource;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

public class NotificationRequest {
    
    private String token;
    private String title;
    private String message;
    private String orderId;
    private String type;

    // ── Getters ───────────────────────────────────────────────────
    public String getToken()   { return token;   }
    public String getTitle()   { return title;   }
    public String getMessage() { return message; }
    public String getOrderId() { return orderId; }
    public String getType()    { return type;    }

    // ── Setters ───────────────────────────────────────────────────
    public void setToken(String token)     { this.token   = token;   }
    public void setTitle(String title)     { this.title   = title;   }
    public void setMessage(String message) { this.message = message; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public void setType(String type)       { this.type    = type;    }

    @Override
    public String toString() {
        return "NotificationRequest{"
                + "token='" + token + '\''
                + ", title='" + title + '\''
                + ", message='" + message + '\''
                + ", orderId='" + orderId + '\''
                + ", type='" + type + '\''
                + '}';
    }
    
}
