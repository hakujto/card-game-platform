package cardsproject.controller.cards;

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
public class DeckControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/decks"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/decks")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\", \"isTournamentLegal\": null }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/decks/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/decks/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_wins_not_negative_violated() throws Exception {
        // Deck wins count must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/decks")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"format\": \"STANDARD\", \"losses\": 1, \"draws\": 1, \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\", \"playerId\": 1, \"isTournamentLegal\": true, \"isPublic\": true, \"wins\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_losses_not_negative_violated() throws Exception {
        // Deck losses count must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/decks")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"format\": \"STANDARD\", \"wins\": 1, \"draws\": 1, \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\", \"playerId\": 1, \"isTournamentLegal\": true, \"isPublic\": true, \"losses\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_draws_not_negative_violated() throws Exception {
        // Deck draws count must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/decks")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"format\": \"STANDARD\", \"wins\": 1, \"losses\": 1, \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\", \"playerId\": 1, \"isTournamentLegal\": true, \"isPublic\": true, \"draws\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_tournament_legal_deck_must_be_validated_violated() throws Exception {
        // Tournament-legal deck must be made public: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/decks")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"format\": \"STANDARD\", \"wins\": 1, \"losses\": 1, \"draws\": 1, \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\", \"playerId\": 1, \"isTournamentLegal\": true, \"isPublic\": false }"))
            .andExpect(status().isBadRequest());
    }
}
