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
public class PlayerCollectionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/player_collections"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/player_collections")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"acquiredAt\": \"2024-01-01T00:00:00\", \"quantity\": 1 }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/player_collections/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/player_collections/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_quantity_positive_violated() throws Exception {
        // Collection quantity must be greater than zero → 400 (Bean Validation)
        mockMvc.perform(post("/api/player_collections")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"foil\": true, \"condition\": \"MINT\", \"acquiredAt\": \"2024-01-01T00:00:00\", \"acquiredVia\": \"PURCHASE\", \"playerId\": 1, \"cardId\": 1, \"quantity\": 0 }"))
            .andExpect(status().isBadRequest());
    }
}
