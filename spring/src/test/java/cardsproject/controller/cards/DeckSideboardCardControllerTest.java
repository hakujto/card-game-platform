package cardsproject.controller.cards;

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
public class DeckSideboardCardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/deck_sideboard_cards"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/deck_sideboard_cards")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"quantity\": 1 }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/deck_sideboard_cards/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/deck_sideboard_cards/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
}
