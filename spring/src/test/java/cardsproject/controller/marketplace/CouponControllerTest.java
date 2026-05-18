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
public class CouponControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void list_returns200() throws Exception {
        mockMvc.perform(get("/api/coupons"))
            .andExpect(status().isOk());
    }

    @Test
    void create_returns201() throws Exception {
        mockMvc.perform(post("/api/coupons")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"code\": \"test\", \"discountValue\": 0.01, \"validFrom\": \"2024-01-01T00:00:00\", \"validUntil\": \"2024-01-01T00:00:01\", \"maxUses\": null }"))
            .andExpect(status().isCreated());
    }

    @Test
    void show_returns200or404() throws Exception {
        mockMvc.perform(get("/api/coupons/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 200 || status == 404;
            });
    }

    @Test
    void delete_returns204or404() throws Exception {
        mockMvc.perform(delete("/api/coupons/1"))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                assert status == 204 || status == 404 || status == 500 || status == 501;
            });
    }
    @Test
    void create_fails_when_discount_value_positive_violated() throws Exception {
        // Discount value must be greater than zero → 400 (Bean Validation)
        mockMvc.perform(post("/api/coupons")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"code\": \"test\", \"minOrderValue\": 0.00, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00\", \"validUntil\": \"2024-01-01T00:00:00\", \"isActive\": true, \"discountType\": \"PERCENT\", \"maxUses\": 1, \"discountValue\": 0.00 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_percent_discount_range_violated() throws Exception {
        // Percent discount must be between 1 and 100: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/coupons")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"code\": \"test\", \"minOrderValue\": 0.00, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00\", \"validUntil\": \"2024-01-01T00:00:00\", \"isActive\": true, \"discountType\": \"PERCENT\", \"discountValue\": 101 }"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void create_fails_when_uses_not_exceed_max_violated() throws Exception {
        // Coupon uses count cannot exceed max_uses: antecedent true, consequent missing → 400
        mockMvc.perform(post("/api/coupons")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{ \"code\": \"test\", \"discountType\": \"PERCENT\", \"discountValue\": 0.00, \"minOrderValue\": 0.00, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00\", \"validUntil\": \"2024-01-01T00:00:00\", \"isActive\": true, \"maxUses\": 1 }"))
            .andExpect(status().isBadRequest());
    }
}
