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
            .content("{ \"quantity\": 1, \"foil\": true, \"acquiredAt\": LocalDateTime.of(2024, 1, 1, 0, 0) }"))
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
                assert status == 204 || status == 404;
            });
    }
}
