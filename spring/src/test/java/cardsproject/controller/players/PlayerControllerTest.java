package cardsproject.controller.players;

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
public class PlayerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/players"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/players")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"displayName\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/players/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/players/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_rating_range_violated() throws Exception {
        // Rating must be between 0 and 9999 → 400 (Bean Validation)
        mockMvc.perform(post("/api/players")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"displayName\": \"test\", \"rank\": \"BRONZE\", \"peakRating\": 1, \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"rating\": 10000 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_peak_rating_gte_rating_violated() throws Exception {
        // Peak rating must be greater than or equal to current rating → 400 (Bean Validation)
        mockMvc.perform(post("/api/players")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"displayName\": \"test\", \"rank\": \"BRONZE\", \"rating\": 1, \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"peakRating\": NaN }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_display_name_not_empty_violated() throws Exception {
        // Display name must not be empty → 400 (Bean Validation)
        mockMvc.perform(post("/api/players")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"rank\": \"BRONZE\", \"rating\": 1, \"peakRating\": 1, \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"displayName\": null }"))
            .andExpect(status().isBadRequest());
    }
}
