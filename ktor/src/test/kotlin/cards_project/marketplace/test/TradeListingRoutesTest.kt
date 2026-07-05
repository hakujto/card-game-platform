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

class TradeListingRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { tradeListingRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/trade_listings")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/trade_listings?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/trade_listings/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_listings/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/trade_listings/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

    @Test fun `transition Active to Sold returns 200`() = testApp {
        val created = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_listings/$id/transitions/active-to-sold")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Active to Expired returns 200`() = testApp {
        val created = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_listings/$id/transitions/active-to-expired")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Active to Cancelled returns 403 for wrong role`() = testApp {
        val created = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_listings/$id/transitions/active-to-cancelled") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Active to Cancelled returns 200 for allowed role`() = testApp {
        val created = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_listings/$id/transitions/active-to-cancelled") {
            header("X-User-Role", "Seller")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Sold to Active returns 409`() = testApp {
        val created = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/trade_listings/$id/transitions/active-to-sold")
        val r = client.patch("/api/trade_listings/$id/transitions/sold-to-active")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

    @Test fun `transition Expired to Active returns 409`() = testApp {
        val created = client.post("/api/trade_listings") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/trade_listings/$id/transitions/active-to-expired")
        val r = client.patch("/api/trade_listings/$id/transitions/expired-to-active")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

}
