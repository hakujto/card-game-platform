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
public class OrderItemControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/order_items"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/order_items")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"quantity\": 1, \"priceAtPurchase\": 0.00 }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/order_items/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/order_items/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_quantity_positive_violated() throws Exception {
        // Order item quantity must be greater than zero → 400 (Bean Validation)
        mockMvc.perform(post("/api/order_items")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"priceAtPurchase\": 0.00, \"foil\": true, \"quantity\": 0 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_price_not_negative_violated() throws Exception {
        // Price at purchase must not be negative → 400 (Bean Validation)
        mockMvc.perform(post("/api/order_items")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"quantity\": 1, \"foil\": true, \"priceAtPurchase\": -1 }"))
            .andExpect(status().isBadRequest());
    }
}
