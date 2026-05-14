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
public class TournamentRoundControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/tournament_rounds"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/tournament_rounds")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"roundNumber\": 1 }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/tournament_rounds/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/tournament_rounds/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_ended_after_started_violated() throws Exception {
        // Round end time must be after start time: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/tournament_rounds")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"roundNumber\": 1, \"status\": \"PENDING\", \"timeLimitMinutes\": 1, \"endedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isBadRequest());
    }
}
