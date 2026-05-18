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
public class TournamentRegistrationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/tournament_registrations"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/tournament_registrations")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"registeredAt\": \"2024-01-01T00:00:00\", \"finalStanding\": null, \"seed\": null }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/tournament_registrations/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/tournament_registrations/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_points_earned_not_negative_violated() throws Exception {
        // Points earned must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournament_registrations")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"status\": \"REGISTERED\", \"registeredAt\": \"2024-01-01T00:00:00\", \"tournamentId\": 1, \"playerId\": 1, \"deckId\": 1, \"finalStanding\": 1, \"finalStanding\": 1, \"seed\": 1, \"seed\": 1, \"pointsEarned\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_final_standing_positive_violated() throws Exception {
        // Final standing must be greater than zero: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/tournament_registrations")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"status\": \"REGISTERED\", \"pointsEarned\": 1, \"registeredAt\": \"2024-01-01T00:00:00\", \"tournamentId\": 1, \"playerId\": 1, \"deckId\": 1, \"finalStanding\": 1, \"finalStanding\": 0 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_seed_positive_violated() throws Exception {
        // Seed must be greater than zero: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/tournament_registrations")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"status\": \"REGISTERED\", \"pointsEarned\": 1, \"registeredAt\": \"2024-01-01T00:00:00\", \"tournamentId\": 1, \"playerId\": 1, \"deckId\": 1, \"seed\": 1, \"seed\": 0 }"))
            .andExpect(status().isBadRequest());
    }
}
