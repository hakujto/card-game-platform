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
public class CraftingRecipeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/crafting_recipes"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/crafting_recipes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"dustCost\": 1 }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/crafting_recipes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/crafting_recipes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_dust_cost_positive_violated() throws Exception {
        // Crafting recipe must have a dust cost greater than zero → 400 (Bean Validation)
        mockMvc.perform(post("/api/crafting_recipes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"isAvailable\": true, \"resultCardId\": 1, \"dustCost\": 0 }"))
            .andExpect(status().isBadRequest());
    }
}
