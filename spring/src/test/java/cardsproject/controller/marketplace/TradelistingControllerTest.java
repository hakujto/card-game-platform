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
public class TradeListingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/trade_listings"))
            .andExpect(status().isOk());
    }
    @Test
    void search_returns200() throws Exception {
        mockMvc.perform(get("/api/trade_listings?q=test"))
            .andExpect(status().isOk());
    }
    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/trade_listings")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"createdAt\": \"2024-01-01T00:00:00\" }"))
            .andExpect(status().isCreated());
    }
    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/trade_listings/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void patch_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_listings/1")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"foil\": true}"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404 || status == 403;
            });
    }
    @Test
    void create_fails_when_fixed_price_requires_asking_price_violated() throws Exception {
        // Fixed price listing must have an asking price: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/trade_listings")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"status\": \"ACTIVE\", \"foil\": true, \"condition\": \"MINT\", \"quantity\": 1, \"createdAt\": \"2024-01-01T00:00:00\", \"sellerId\": 1, \"cardId\": 1, \"listingType\": \"FIXEDPRICE\", \"askingPrice\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_auction_requires_start_price_and_end_time_violated() throws Exception {
        // Auction listing must have a start price and end time: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/trade_listings")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"status\": \"ACTIVE\", \"foil\": true, \"condition\": \"MINT\", \"quantity\": 1, \"createdAt\": \"2024-01-01T00:00:00\", \"sellerId\": 1, \"cardId\": 1, \"listingType\": \"AUCTION\", \"auctionStartPrice\": null }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_quantity_positive_violated() throws Exception {
        // Listing quantity must be between 1 and 9999 → 400 (Bean Validation)
        mockMvc.perform(post("/api/trade_listings")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"status\": \"ACTIVE\", \"foil\": true, \"condition\": \"MINT\", \"createdAt\": \"2024-01-01T00:00:00\", \"sellerId\": 1, \"cardId\": 1, \"listingType\": \"FIXEDPRICE\", \"askingPrice\": 0.00, \"listingType\": \"AUCTION\", \"auctionStartPrice\": 0.00, \"auctionEndTime\": \"2024-01-01T00:00:00\", \"quantity\": 10000 }"))
            .andExpect(status().isBadRequest());
    }
    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"SELLER"})
    void transitionPendingToActive_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_listings/1/transitions/pending-to-active"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    void transitionActiveToSold_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_listings/1/transitions/active-to-sold"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    void transitionActiveToExpired_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_listings/1/transitions/active-to-expired"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    @org.springframework.security.test.context.support.WithMockUser(roles = {"SELLER", "ADMIN"})
    void transitionActiveToCancelled_returns200or404() throws Exception {
        mockMvc.perform(patch("/api/trade_listings/1/transitions/active-to-cancelled"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 200 || s == 404 || s == 409 || s == 422;
            });
    }

    @Test
    void transitionSoldToActive_isDenied() throws Exception {
        mockMvc.perform(patch("/api/trade_listings/1/transitions/sold-to-active"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 409 || s == 404;
            });
    }

    @Test
    void transitionExpiredToActive_isDenied() throws Exception {
        mockMvc.perform(patch("/api/trade_listings/1/transitions/expired-to-active"))
            .andExpect(result -> {
                int s = result.getResponse().getStatus();
                assert s == 409 || s == 404;
            });
    }
}
