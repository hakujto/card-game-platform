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
public class TradeDisputeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/trade_disputes"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/trade_disputes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"reason\": \"ITEMNOTRECEIVED\", \"description\": \"test\", \"openedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/trade_disputes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/trade_disputes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_resolved_at_requires_terminal_status_violated() throws Exception {
        // resolved_at_requires_terminal_status: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/trade_disputes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"reason\": \"ITEMNOTRECEIVED\", \"description\": \"test\", \"status\": \"OPEN\", \"openedAt\": \"2024-01-01T00:00:00\", \"resolvedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isBadRequest());
    }
}
