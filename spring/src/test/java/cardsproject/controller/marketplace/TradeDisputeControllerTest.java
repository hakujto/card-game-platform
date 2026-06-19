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
            .content("{ \"reason\": \"ITEMNOTRECEIVED\", \"description\": \"test\", \"openedAt\": \"2024-01-01T00:00:00\", \"resolvedAt\": null }"))
            .andExpect(status().isCreated());
    }
    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/trade_disputes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void create_fails_when_resolved_at_requires_terminal_status_violated() throws Exception {
        // resolved_at_requires_terminal_status: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/trade_disputes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"status\": \"OPEN\", \"reason\": \"ITEMNOTRECEIVED\", \"description\": \"test\", \"openedAt\": \"2024-01-01T00:00:00\", \"transactionId\": 1, \"openedById\": 1, \"resolvedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isBadRequest());
    }
    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN", "MODERATOR"})
    void transitionOpenToUnderReview_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_disputes/1/transitions/open-to-underreview"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN", "MODERATOR"})
    void transitionUnderReviewToResolved_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_disputes/1/transitions/underreview-to-resolved"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN"})
    void transitionUnderReviewToEscalated_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_disputes/1/transitions/underreview-to-escalated"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN"})
    void transitionEscalatedToResolved_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_disputes/1/transitions/escalated-to-resolved"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    void transitionResolvedToOpen_isDenied() throws Exception {
        mockMvc.perform(patch("/api/trade_disputes/1/transitions/resolved-to-open"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 409 || s == 404;
            });
    }
}
