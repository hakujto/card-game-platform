package cardsproject.controller.tournaments;

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
public class AwardedPrizeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/awarded_prizes"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/awarded_prizes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"finalPlacement\": 1, \"awardedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/awarded_prizes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/awarded_prizes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_claimed_requires_claimed_at_violated() throws Exception {
        // Claimed prize must have a claimed_at timestamp: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/awarded_prizes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"finalPlacement\": 1, \"awardedAt\": \"2024-01-01T00:00:00\", \"claimed\": true, \"claimedAt\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_final_placement_positive_violated() throws Exception {
        // Final placement must be greater than zero → 400 (Bean Validation)
        mockMvc.perform(post("/api/awarded_prizes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"awardedAt\": \"2024-01-01T00:00:00\", \"claimed\": true, \"claimedAt\": \"2024-01-01T00:00:00\", \"finalPlacement\": 0 }"))
            .andExpect(status().isBadRequest());
    }
}
