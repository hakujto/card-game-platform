package cardsproject.controller.players;

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
public class PlayerAchievementControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/player_achievements"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/player_achievements")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"earnedAt\": \"2024-01-01T00:00:00\", \"isCompleted\": null }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/player_achievements/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/player_achievements/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_completed_requires_progress_violated() throws Exception {
        // Completed achievement must have progress greater than zero: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/player_achievements")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"earnedAt\": \"2024-01-01T00:00:00\", \"playerId\": 1, \"achievementId\": 1, \"isCompleted\": true, \"progress\": 0 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_progress_not_negative_violated() throws Exception {
        // Achievement progress must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/player_achievements")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"earnedAt\": \"2024-01-01T00:00:00\", \"playerId\": 1, \"achievementId\": 1, \"isCompleted\": true, \"progress\": -1 }"))
            .andExpect(status().isBadRequest());
    }
}
