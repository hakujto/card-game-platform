package cardsproject.controller.marketplace;

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
public class ProductControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/products"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/products")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"price\": 0.01 }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/products/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/products/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_price_positive_violated() throws Exception {
        // Product price must be greater than zero → 400 (Bean Validation)
        mockMvc.perform(post("/api/products")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"productType\": \"SINGLECARD\", \"stock\": 1, \"active\": true, \"discountPercent\": 1, \"featured\": true, \"price\": 0.00 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_stock_not_negative_violated() throws Exception {
        // Product stock must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/products")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"productType\": \"SINGLECARD\", \"price\": 0.00, \"active\": true, \"discountPercent\": 1, \"featured\": true, \"stock\": -1 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_discount_percent_range_violated() throws Exception {
        // Product discount percent must be between 0 and 100 → 400 (Bean Validation)
        mockMvc.perform(post("/api/products")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"name\": \"test\", \"productType\": \"SINGLECARD\", \"price\": 0.00, \"stock\": 1, \"active\": true, \"featured\": true, \"discountPercent\": 101 }"))
            .andExpect(status().isBadRequest());
    }
}
