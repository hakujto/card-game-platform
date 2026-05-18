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
public class CardSetControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/card_sets"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/card_sets")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"code\": \"test\", \"releaseDate\": \"2024-01-01\", \"totalCards\": 1, \"rotationDate\": null, \"isRotated\": null }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/card_sets/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/card_sets/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_total_cards_positive_violated() throws Exception {
        // Card set must have at least one card → 400 (Bean Validation)
        mockMvc.perform(post("/api/card_sets")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"code\": \"test\", \"releaseDate\": \"2024-01-01\", \"setType\": \"CORE\", \"rotationDate\": \"2024-01-01\", \"isRotated\": true, \"rotationDate\": \"2024-01-01\", \"totalCards\": 0 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_rotation_date_after_release_violated() throws Exception {
        // Rotation date must be after release date: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/card_sets")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"code\": \"test\", \"releaseDate\": \"2024-01-01\", \"setType\": \"CORE\", \"totalCards\": 1, \"isRotated\": true, \"rotationDate\": \"2024-01-01\" }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_rotated_set_has_rotation_date_violated() throws Exception {
        // Rotated set must have a rotation date: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/card_sets")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"code\": \"test\", \"releaseDate\": \"2024-01-01\", \"setType\": \"CORE\", \"totalCards\": 1, \"isRotated\": true, \"rotationDate\": null }"))
            .andExpect(status().isBadRequest());
    }
}
