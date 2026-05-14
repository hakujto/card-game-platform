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
public class GameControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/games"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/games")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"gameNumber\": 1 }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/games/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/games/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_game_number_range_violated() throws Exception {
        // Game number must be between 1 and 3 (best-of-3) → 400 (Bean Validation)
        mockMvc.perform(post("/api/games")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"turnsPlayed\": 1, \"turnsPlayed\": 1, \"durationSeconds\": 1, \"durationSeconds\": 1, \"gameNumber\": 4 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_turns_played_positive_violated() throws Exception {
        // Turns played must be greater than zero: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/games")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"gameNumber\": 1, \"turnsPlayed\": 1, \"turnsPlayed\": 0 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_duration_positive_violated() throws Exception {
        // Game duration must be greater than zero: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/games")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"gameNumber\": 1, \"durationSeconds\": 1, \"durationSeconds\": 0 }"))
            .andExpect(status().isBadRequest());
    }
}
