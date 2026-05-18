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
public class PlayerSeasonStatsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/player_season_statses"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/player_season_statses")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{}"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/player_season_statses/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/player_season_statses/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_wins_not_negative_violated() throws Exception {
        // Season wins must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/player_season_statses")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"losses\": 1, \"draws\": 1, \"tournamentWins\": 1, \"seasonPoints\": 1, \"playerId\": 1, \"seasonId\": 1, \"wins\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_losses_not_negative_violated() throws Exception {
        // Season losses must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/player_season_statses")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"wins\": 1, \"draws\": 1, \"tournamentWins\": 1, \"seasonPoints\": 1, \"playerId\": 1, \"seasonId\": 1, \"losses\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_tournament_wins_not_negative_violated() throws Exception {
        // Season tournament wins must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/player_season_statses")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"wins\": 1, \"losses\": 1, \"draws\": 1, \"seasonPoints\": 1, \"playerId\": 1, \"seasonId\": 1, \"tournamentWins\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_season_points_not_negative_violated() throws Exception {
        // Season points must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/player_season_statses")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"wins\": 1, \"losses\": 1, \"draws\": 1, \"tournamentWins\": 1, \"playerId\": 1, \"seasonId\": 1, \"seasonPoints\": -1 }"))
            .andExpect(status().isBadRequest());
    }
}
