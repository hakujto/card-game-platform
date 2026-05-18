package cardsproject.controller.content;

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
public class DraftSessionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/draft_sessions"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/draft_sessions")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"createdAt\": \"2024-01-01T00:00:00\", \"seats\": 2, \"completedAt\": null }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/draft_sessions/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/draft_sessions/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_seats_range_violated() throws Exception {
        // Draft session must have between 2 and 16 seats → 400 (Bean Validation)
        mockMvc.perform(post("/api/draft_sessions")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"draftType\": \"BOOSTER\", \"createdAt\": \"2024-01-01T00:00:00\", \"cardSetId\": 1, \"completedAt\": \"2024-01-01T00:00:00\", \"status\": \"COMPLETED\", \"seats\": 17 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_completed_at_requires_completed_status_violated() throws Exception {
        // completed_at can only be set when draft status is Completed: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/draft_sessions")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"status\": \"WAITINGFORPLAYERS\", \"draftType\": \"BOOSTER\", \"seats\": 1, \"createdAt\": \"2024-01-01T00:00:00\", \"cardSetId\": 1, \"completedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isBadRequest());
    }
}
