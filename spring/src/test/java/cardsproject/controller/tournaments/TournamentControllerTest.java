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
public class TournamentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/tournaments"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"maxPlayers\": 2, \"startTime\": \"2024-01-01T00:00:00\", \"createdAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/tournaments/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/tournaments/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_max_players_positive_violated() throws Exception {
        // Tournament must allow between 2 and 512 players → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"status\": \"DRAFT\", \"entryFee\": 0.00, \"prizePool\": 0.00, \"startTime\": \"2024-01-01T00:00:00\", \"isOnline\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"endTime\": \"2024-01-01T00:00:00\", \"maxPlayers\": 513 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_entry_fee_not_negative_violated() throws Exception {
        // Entry fee must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"status\": \"DRAFT\", \"maxPlayers\": 1, \"prizePool\": 0.00, \"startTime\": \"2024-01-01T00:00:00\", \"isOnline\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"endTime\": \"2024-01-01T00:00:00\", \"entryFee\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_prize_pool_not_negative_violated() throws Exception {
        // Prize pool must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"status\": \"DRAFT\", \"maxPlayers\": 1, \"entryFee\": 0.00, \"startTime\": \"2024-01-01T00:00:00\", \"isOnline\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"endTime\": \"2024-01-01T00:00:00\", \"prizePool\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_end_time_after_start_violated() throws Exception {
        // End time must be after start time: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"status\": \"DRAFT\", \"maxPlayers\": 1, \"entryFee\": 0.00, \"prizePool\": 0.00, \"startTime\": \"2024-01-01T00:00:00\", \"isOnline\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"endTime\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isBadRequest());
    }
}
