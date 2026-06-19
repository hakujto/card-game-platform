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
public class ArticleControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/articles"))
            .andExpect(status().isOk());
    }
    @Test
    void search_returns200() throws Exception {
        mockMvc.perform(get("/api/articles?q=test"))
            .andExpect(status().isOk());
    }
    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/articles")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"slug\": \"test\", \"body\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }
    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/articles/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void update_returns200or404() throws Exception {
        mockMvc.perform(put("/api/articles/1")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"slug\": \"test\", \"body\": \"test\", \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void patch_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/articles/1")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"title\": \"test\"}"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void create_fails_when_published_requires_published_at_violated() throws Exception {
        // Published article must have a published_at timestamp: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/articles")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"slug\": \"test\", \"body\": \"test\", \"articleType\": \"GUIDE\", \"language\": \"EN\", \"viewCount\": 1, \"likesCount\": 1, \"isFeatured\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\", \"authorId\": 1, \"status\": \"PUBLISHED\", \"publishedAt\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_view_count_not_negative_violated() throws Exception {
        // Article view count must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/articles")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"slug\": \"test\", \"body\": \"test\", \"articleType\": \"GUIDE\", \"language\": \"EN\", \"likesCount\": 1, \"isFeatured\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\", \"authorId\": 1, \"status\": \"PUBLISHED\", \"publishedAt\": \"2024-01-01T00:00:00\", \"viewCount\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_likes_count_not_negative_violated() throws Exception {
        // Article likes count must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/articles")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"title\": \"test\", \"slug\": \"test\", \"body\": \"test\", \"articleType\": \"GUIDE\", \"language\": \"EN\", \"viewCount\": 1, \"isFeatured\": true, \"createdAt\": \"2024-01-01T00:00:00\", \"updatedAt\": \"2024-01-01T00:00:00\", \"authorId\": 1, \"status\": \"PUBLISHED\", \"publishedAt\": \"2024-01-01T00:00:00\", \"likesCount\": -1 }"))
            .andExpect(status().isBadRequest());
    }
    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"EDITOR", "ADMIN"})
    void transitionDraftToPublished_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/articles/1/transitions/draft-to-published"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"EDITOR", "ADMIN"})
    void transitionPublishedToArchived_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/articles/1/transitions/published-to-archived"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"ADMIN"})
    void transitionArchivedToDraft_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/articles/1/transitions/archived-to-draft"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    void transitionPublishedToDraft_isDenied() throws Exception {
        mockMvc.perform(patch("/api/articles/1/transitions/published-to-draft"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 409 || s == 404;
            });
    }
}
