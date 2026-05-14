package cardsproject.controller.tournaments;

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
public class MatchControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/matches"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/matches")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{}"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/matches/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/matches/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_wins_not_negative_violated() throws Exception {
        // Win counts must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/matches")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"player2Wins\": 1, \"status\": \"BYE\", \"player2\": null, \"player1Wins\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_max_three_games_violated() throws Exception {
        // Win counts cannot exceed 2 in a best-of-3 match → 400 (Bean Validation)
        mockMvc.perform(post("/api/matches")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"player2Wins\": 1, \"status\": \"BYE\", \"player2\": null, \"player1Wins\": 3 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_bye_has_no_player2_violated() throws Exception {
        // BYE match must not have a second player: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/matches")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"player1Wins\": 1, \"player2Wins\": 1, \"status\": \"BYE\", \"player2\": \"x\" }"))
            .andExpect(status().isBadRequest());
    }
}
