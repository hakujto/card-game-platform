package cardsproject.controller.tournaments;

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
public class TournamentPrizeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/tournament_prizes"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/tournament_prizes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"placementFrom\": 1, \"placementTo\": 1, \"prizeType\": \"CURRENCY\" }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/tournament_prizes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/tournament_prizes/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_placement_from_positive_violated() throws Exception {
        // placement_from must be greater than zero → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournament_prizes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"placementTo\": 1, \"prizeType\": \"CURRENCY\", \"amount\": 0.00, \"seasonPoints\": 1, \"placementFrom\": 0 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_amount_not_negative_violated() throws Exception {
        // Prize amount must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/tournament_prizes")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"placementFrom\": 1, \"placementTo\": 1, \"prizeType\": \"CURRENCY\", \"seasonPoints\": 1, \"amount\": -1 }"))
            .andExpect(status().isBadRequest());
    }
}
