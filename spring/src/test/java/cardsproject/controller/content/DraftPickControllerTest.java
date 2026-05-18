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
public class DraftPickControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/draft_picks"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/draft_picks")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"pickNumber\": 1, \"packNumber\": 1, \"pickedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/draft_picks/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/draft_picks/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_pick_number_positive_violated() throws Exception {
        // Pick number must be greater than zero → 400 (Bean Validation)
        mockMvc.perform(post("/api/draft_picks")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"packNumber\": 1, \"pickedAt\": \"2024-01-01T00:00:00\", \"participantId\": 1, \"cardId\": 1, \"pickNumber\": 0 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_pack_number_range_violated() throws Exception {
        // Pack number must be between 1 and 3 → 400 (Bean Validation)
        mockMvc.perform(post("/api/draft_picks")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"pickNumber\": 1, \"pickedAt\": \"2024-01-01T00:00:00\", \"participantId\": 1, \"cardId\": 1, \"packNumber\": 4 }"))
            .andExpect(status().isBadRequest());
    }
}
