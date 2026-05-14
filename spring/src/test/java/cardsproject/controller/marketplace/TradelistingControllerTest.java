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
public class TradelistingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/tradelistings"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/tradelistings")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"createdAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/tradelistings/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/tradelistings/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404;
            });
    }
    @Test
    void create_fails_when_fixed_price_requires_asking_price_violated() throws Exception {
        // Fixed price listing must have an asking price: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/tradelistings")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"foil\": true, \"condition\": \"MINT\", \"quantity\": 1, \"status\": \"ACTIVE\", \"createdAt\": \"2024-01-01T00:00:00\", \"listingType\": \"FIXEDPRICE\", \"askingPrice\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_auction_requires_start_price_and_end_time_violated() throws Exception {
        // Auction listing must have a start price and end time: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/tradelistings")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"foil\": true, \"condition\": \"MINT\", \"quantity\": 1, \"status\": \"ACTIVE\", \"createdAt\": \"2024-01-01T00:00:00\", \"listingType\": \"AUCTION\", \"auctionStartPrice\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_quantity_positive_violated() throws Exception {
        // Listing quantity must be between 1 and 9999 → 400 (Bean Validation)
        mockMvc.perform(post("/api/tradelistings")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"foil\": true, \"condition\": \"MINT\", \"status\": \"ACTIVE\", \"createdAt\": \"2024-01-01T00:00:00\", \"listingType\": \"FIXEDPRICE\", \"askingPrice\": 0.00, \"listingType\": \"AUCTION\", \"auctionStartPrice\": 0.00, \"auctionEndTime\": \"2024-01-01T00:00:00\", \"quantity\": 10000 }"))
            .andExpect(status().isBadRequest());
    }
}
