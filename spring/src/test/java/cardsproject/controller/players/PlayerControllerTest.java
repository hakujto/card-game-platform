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
public class PlayerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/players"))
            .andExpect(status().isOk());
    }
    @Test
    void search_returns200() throws Exception {
        mockMvc.perform(get("/api/players?q=test"))
            .andExpect(status().isOk());
    }
    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/players")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"publicId\": \"00000000-0000-0000-0000-000000000001\", \"displayName\": \"test_player_001\", \"createdAt\": \"2024-01-01T00:00:00\", \"peakRating\": 1000, \"countryCode\": \"AA\", \"rank\": \"Bronze\", \"rating\": 1000 }"))
            .andExpect(status().isCreated());
    }
    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/players/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void patch_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/players/1")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"publicId\": \"00000000-0000-0000-0000-000000000001\"}"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void create_fails_when_rating_range_violated() throws Exception {
        // Rating must be between 0 and 9999 → 400 (Bean Validation)
        mockMvc.perform(post("/api/players")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"publicId\": \"00000000-0000-0000-0000-000000000001\", \"displayName\": \"test\", \"rank\": \"BRONZE\", \"peakRating\": 1, \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"rating\": 10000 }"))
            .andExpect(status().isBadRequest());
    }
}
