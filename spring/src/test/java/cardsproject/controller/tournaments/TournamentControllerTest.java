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
    void search_returns200() throws Exception {
        mockMvc.perform(get("/api/tournaments?q=test"))
            .andExpect(status().isOk());
    }
    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"publicId\": \"00000000-0000-0000-0000-000000000001\", \"name\": \"Test Tournament Alpha\", \"maxPlayers\": 8, \"startTime\": \"2024-01-01T00:00:00\", \"createdAt\": \"2024-01-01T00:00:00\", \"endTime\": null, \"entryFee\": 0, \"prizePool\": 0 }"))
            .andExpect(status().isCreated());
    }
    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/tournaments/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void update_returns200or404() throws Exception {
        mockMvc.perform(put("/api/tournaments/1")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"publicId\": \"00000000-0000-0000-0000-000000000001\", \"name\": \"Test Tournament Alpha\", \"maxPlayers\": 8, \"startTime\": \"2024-01-01T00:00:00\", \"createdAt\": \"2024-01-01T00:00:00\", \"endTime\": null, \"entryFee\": 0, \"prizePool\": 0 }"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void patch_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/tournaments/1")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"publicId\": \"00000000-0000-0000-0000-000000000001\"}"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void create_fails_when_max_players_positive_violated() throws Exception {
        // Tournament must allow between 2 and 512 players → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"publicId\": \"00000000-0000-0000-0000-000000000001\", \"name\": \"test\", \"status\": \"DRAFT\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"entryFee\": 0.00, \"prizePool\": 0.00, \"startTime\": \"2024-01-01T00:00:00\", \"isOnline\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"seasonId\": 1, \"organizerId\": 1, \"endTime\": \"2024-01-01T00:00:00\", \"maxPlayers\": 513 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_entry_fee_not_negative_violated() throws Exception {
        // Entry fee must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"publicId\": \"00000000-0000-0000-0000-000000000001\", \"name\": \"test\", \"status\": \"DRAFT\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"maxPlayers\": 1, \"prizePool\": 0.00, \"startTime\": \"2024-01-01T00:00:00\", \"isOnline\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"seasonId\": 1, \"organizerId\": 1, \"endTime\": \"2024-01-01T00:00:00\", \"entryFee\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_prize_pool_not_negative_violated() throws Exception {
        // Prize pool must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"publicId\": \"00000000-0000-0000-0000-000000000001\", \"name\": \"test\", \"status\": \"DRAFT\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"maxPlayers\": 1, \"entryFee\": 0.00, \"startTime\": \"2024-01-01T00:00:00\", \"isOnline\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"seasonId\": 1, \"organizerId\": 1, \"endTime\": \"2024-01-01T00:00:00\", \"prizePool\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_end_time_after_start_violated() throws Exception {
        // End time must be after start time: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/tournaments")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"publicId\": \"00000000-0000-0000-0000-000000000001\", \"name\": \"test\", \"status\": \"DRAFT\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"maxPlayers\": 1, \"entryFee\": 0.00, \"prizePool\": 0.00, \"startTime\": \"2024-01-01T00:00:00\", \"isOnline\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"seasonId\": 1, \"organizerId\": 1, \"endTime\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isBadRequest());
    }
    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN", "ORGANIZER"})
    void transitionDraftToRegistration_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/tournaments/1/transitions/draft-to-registration"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN", "ORGANIZER"})
    void transitionRegistrationToOngoing_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/tournaments/1/transitions/registration-to-ongoing"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN", "ORGANIZER"})
    void transitionRegistrationToCancelled_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/tournaments/1/transitions/registration-to-cancelled"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN", "ORGANIZER"})
    void transitionOngoingToCompleted_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/tournaments/1/transitions/ongoing-to-completed"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN"})
    void transitionOngoingToCancelled_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/tournaments/1/transitions/ongoing-to-cancelled"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    void transitionCompletedToDraft_isDenied() throws Exception {
        mockMvc.perform(patch("/api/tournaments/1/transitions/completed-to-draft"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 409 || s == 404;
            });
    }

    @Test
    void transitionCancelledToDraft_isDenied() throws Exception {
        mockMvc.perform(patch("/api/tournaments/1/transitions/cancelled-to-draft"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 409 || s == 404;
            });
    }
}
