package cardsproject.controller.marketplace;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class OrderControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/orders"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/orders")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"createdAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/orders/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/orders/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_paid_requires_paid_at_violated() throws Exception {
        // Paid order must have paid_at set: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/orders")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"total\": 0.00, \"discountApplied\": 0.00, \"currency\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\", \"status\": \"PAID\", \"paidAt\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_shipped_requires_tracking_violated() throws Exception {
        // Shipped order must have a tracking number: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/orders")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"total\": 0.00, \"discountApplied\": 0.00, \"currency\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\", \"status\": \"SHIPPED\", \"trackingNumber\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_total_not_negative_violated() throws Exception {
        // Order total must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/orders")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"discountApplied\": 0.00, \"currency\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\", \"status\": \"PAID\", \"paidAt\": \"2024-01-01T00:00:00\", \"status\": \"SHIPPED\", \"trackingNumber\": \"test\", \"total\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_discount_not_exceed_total_violated() throws Exception {
        // Discount applied cannot exceed order total → 400 (Bean Validation)
        mockMvc.perform(post("/api/orders")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"total\": 0.00, \"currency\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\", \"status\": \"PAID\", \"paidAt\": \"2024-01-01T00:00:00\", \"status\": \"SHIPPED\", \"trackingNumber\": \"test\", \"discountApplied\": NaN }"))
            .andExpect(status().isBadRequest());
    }
}
