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
public class CardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/cards"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/cards")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"manaColors\": \"WHITE\", \"description\": \"test\", \"legalFormats\": \"STANDARD\", \"isBanned\": false, \"isRestricted\": false }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/cards/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/cards/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_creature_requires_stats_violated() throws Exception {
        // Creature card must have attack and defense: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/cards")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"rarity\": \"COMMON\", \"manaCost\": 1, \"manaColors\": \"WHITE\", \"description\": \"test\", \"legalFormats\": \"STANDARD\", \"isBanned\": true, \"isRestricted\": true, \"powerLevel\": 1, \"cardType\": \"CREATURE\", \"attack\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_planeswalker_requires_loyalty_violated() throws Exception {
        // Planeswalker card must have loyalty: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/cards")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"rarity\": \"COMMON\", \"manaCost\": 1, \"manaColors\": \"WHITE\", \"description\": \"test\", \"legalFormats\": \"STANDARD\", \"isBanned\": true, \"isRestricted\": true, \"powerLevel\": 1, \"cardType\": \"PLANESWALKER\", \"loyalty\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_mana_cost_range_violated() throws Exception {
        // mana_cost must be between 0 and 20 → 400 (Bean Validation)
        mockMvc.perform(post("/api/cards")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"rarity\": \"COMMON\", \"manaColors\": \"WHITE\", \"description\": \"test\", \"legalFormats\": \"STANDARD\", \"isBanned\": true, \"isRestricted\": true, \"powerLevel\": 1, \"cardType\": \"CREATURE\", \"attack\": 1, \"defense\": 1, \"cardType\": \"PLANESWALKER\", \"loyalty\": 1, \"manaCost\": 21 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_power_level_range_violated() throws Exception {
        // power_level must be between 1 and 10 → 400 (Bean Validation)
        mockMvc.perform(post("/api/cards")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"rarity\": \"COMMON\", \"manaCost\": 1, \"manaColors\": \"WHITE\", \"description\": \"test\", \"legalFormats\": \"STANDARD\", \"isBanned\": true, \"isRestricted\": true, \"cardType\": \"CREATURE\", \"attack\": 1, \"defense\": 1, \"cardType\": \"PLANESWALKER\", \"loyalty\": 1, \"powerLevel\": 11 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_not_banned_and_restricted_violated() throws Exception {
        // Card cannot be both banned and restricted at the same time → 400 (Bean Validation)
        mockMvc.perform(post("/api/cards")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"rarity\": \"COMMON\", \"manaCost\": 1, \"manaColors\": \"WHITE\", \"description\": \"test\", \"legalFormats\": \"STANDARD\", \"powerLevel\": 1, \"cardType\": \"CREATURE\", \"attack\": 1, \"defense\": 1, \"cardType\": \"PLANESWALKER\", \"loyalty\": 1, \"isBanned\": true, \"isRestricted\": true }"))
            .andExpect(status().isBadRequest());
    }
}
