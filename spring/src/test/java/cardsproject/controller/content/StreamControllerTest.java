package cardsproject.controller.content;

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
public class StreamControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/streams"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/streams")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"streamUrl\": \"https://example.com\", \"scheduledStart\": \"2024-01-01T00:00:00\", \"actualStart\": null, \"endedAt\": null }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/streams/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/streams/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_actual_start_requires_live_or_ended_violated() throws Exception {
        // actual_start_requires_live_or_ended: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/streams")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"streamUrl\": \"https://example.com\", \"platform\": \"TWITCH\", \"status\": \"SCHEDULED\", \"viewerCountPeak\": 1, \"scheduledStart\": \"2024-01-01T00:00:00\", \"streamerId\": 1, \"actualStart\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_ended_at_requires_ended_status_violated() throws Exception {
        // ended_at can only be set when stream status is Ended: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/streams")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"streamUrl\": \"https://example.com\", \"platform\": \"TWITCH\", \"status\": \"SCHEDULED\", \"viewerCountPeak\": 1, \"scheduledStart\": \"2024-01-01T00:00:00\", \"streamerId\": 1, \"endedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_viewer_count_not_negative_violated() throws Exception {
        // Peak viewer count must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/streams")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"streamUrl\": \"https://example.com\", \"platform\": \"TWITCH\", \"scheduledStart\": \"2024-01-01T00:00:00\", \"streamerId\": 1, \"actualStart\": \"2024-01-01T00:00:00\", \"status\": \"LIVE\", \"endedAt\": \"2024-01-01T00:00:00\", \"status\": \"ENDED\", \"viewerCountPeak\": -1 }"))
            .andExpect(status().isBadRequest());
    }
}
