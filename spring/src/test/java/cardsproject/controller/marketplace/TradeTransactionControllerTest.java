package cardsproject.controller.marketplace;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class TradeTransactionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/trade_transactions"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/trade_transactions")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"finalPrice\": 0.00, \"platformFee\": 0.00 }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/trade_transactions/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/trade_transactions/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_fee_not_negative_violated() throws Exception {
        // Platform fee must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/trade_transactions")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"finalPrice\": 0.00, \"status\": \"COMPLETED\", \"completedAt\": \"2024-01-01T00:00:00\", \"platformFee\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_completed_requires_completed_at_violated() throws Exception {
        // Completed transaction must have a completed_at timestamp: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/trade_transactions")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"finalPrice\": 0.00, \"platformFee\": 0.00, \"status\": \"COMPLETED\", \"completedAt\": null }"))
            .andExpect(status().isBadRequest());
    }
}
