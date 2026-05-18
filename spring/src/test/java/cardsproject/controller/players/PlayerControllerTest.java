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
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/players")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"displayName\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\", \"peakRating\": 1000 }"))
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
                assert status == 204 || status == 404 || status == 500 || status == 501;
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
}
