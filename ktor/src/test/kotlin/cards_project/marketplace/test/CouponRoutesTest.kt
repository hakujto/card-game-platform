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

class CouponRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { couponRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/coupons")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/coupons?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/coupons") {
            contentType(ContentType.Application.Json)
            setBody("""{"code": "test", "discount_type": "Percent", "discount_value": 1.00, "min_order_value": 1.00, "uses_count": 1, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-12-31T00:00:00", "is_active": true}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/coupons") {
            contentType(ContentType.Application.Json)
            setBody("""{"code": "test", "discount_type": "Percent", "discount_value": 1.00, "min_order_value": 1.00, "uses_count": 1, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-12-31T00:00:00", "is_active": true}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/coupons/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/coupons") {
            contentType(ContentType.Application.Json)
            setBody("""{"code": "test", "discount_type": "Percent", "discount_value": 1.00, "min_order_value": 1.00, "uses_count": 1, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-12-31T00:00:00", "is_active": true}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/coupons/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"code": "test", "discount_type": "Percent", "discount_value": 1.00, "min_order_value": 1.00, "uses_count": 1, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-12-31T00:00:00", "is_active": true}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/coupons/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
