package cards_project.marketplace.test

import cards_project.marketplace.model.*
import cards_project.marketplace.routes.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.server.routing.*
import io.ktor.server.testing.*
import kotlinx.serialization.json.*
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import cards_project.plugins.configureTestDb
import cards_project.plugins.configureSerialization

class TradeBidRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { tradeBidRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/trade_bids")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/trade_bids") {
            contentType(ContentType.Application.Json)
            setBody("""{"amount": 1.00, "placed_at": "2024-01-01T00:00:00", "is_winning": true, "listing_id": 1, "bidder_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/trade_bids") {
            contentType(ContentType.Application.Json)
            setBody("""{"amount": 1.00, "placed_at": "2024-01-01T00:00:00", "is_winning": true, "listing_id": 1, "bidder_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/trade_bids/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/trade_bids/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
