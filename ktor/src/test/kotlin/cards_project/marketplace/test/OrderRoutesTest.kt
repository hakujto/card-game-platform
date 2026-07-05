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

class OrderRoutesTest {

    private val ownerId = 1
    private val ownerHeaders = mapOf("X-User-Id" to ownerId.toString())

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { orderRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/orders")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            ownerHeaders.forEach { (k, v) -> header(k, v) }
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": $ownerId}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            ownerHeaders.forEach { (k, v) -> header(k, v) }
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": $ownerId}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/orders/$id") {
            ownerHeaders.forEach { (k, v) -> header(k, v) }
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get by id returns 403 for non-owner`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            ownerHeaders.forEach { (k, v) -> header(k, v) }
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": $ownerId}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/orders/$id") {
            header("X-User-Id", "9999")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/orders/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

    @Test fun `transition Pending to Paid returns 200`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/orders/$id/transitions/pending-to-paid")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Paid to Processing returns 403 for wrong role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        val r = client.patch("/api/orders/$id/transitions/paid-to-processing") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Paid to Processing returns 200 for allowed role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        val r = client.patch("/api/orders/$id/transitions/paid-to-processing") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Processing to Shipped returns 403 for wrong role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        client.patch("/api/orders/$id/transitions/paid-to-processing") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/orders/$id/transitions/processing-to-shipped") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Processing to Shipped returns 200 for allowed role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        client.patch("/api/orders/$id/transitions/paid-to-processing") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/orders/$id/transitions/processing-to-shipped") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Shipped to Completed returns 403 for wrong role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        client.patch("/api/orders/$id/transitions/paid-to-processing") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/processing-to-shipped") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/orders/$id/transitions/shipped-to-completed") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Shipped to Completed returns 200 for allowed role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        client.patch("/api/orders/$id/transitions/paid-to-processing") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/processing-to-shipped") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/orders/$id/transitions/shipped-to-completed") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Pending to Cancelled returns 200`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/orders/$id/transitions/pending-to-cancelled")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Paid to Cancelled returns 403 for wrong role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        val r = client.patch("/api/orders/$id/transitions/paid-to-cancelled") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Paid to Cancelled returns 200 for allowed role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        val r = client.patch("/api/orders/$id/transitions/paid-to-cancelled") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Completed to Refunded returns 403 for wrong role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        client.patch("/api/orders/$id/transitions/paid-to-processing") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/processing-to-shipped") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/shipped-to-completed") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/orders/$id/transitions/completed-to-refunded") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Completed to Refunded returns 200 for allowed role`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        client.patch("/api/orders/$id/transitions/paid-to-processing") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/processing-to-shipped") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/shipped-to-completed") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/orders/$id/transitions/completed-to-refunded") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Refunded to Completed returns 409`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        client.patch("/api/orders/$id/transitions/paid-to-processing") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/processing-to-shipped") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/shipped-to-completed") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/completed-to-refunded") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/orders/$id/transitions/refunded-to-completed")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

    @Test fun `transition Completed to Cancelled returns 409`() = testApp {
        val created = client.post("/api/orders") {
            contentType(ContentType.Application.Json)
            setBody("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/orders/$id/transitions/pending-to-paid")
        client.patch("/api/orders/$id/transitions/paid-to-processing") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/processing-to-shipped") { header("X-User-Role", "Admin") }
        client.patch("/api/orders/$id/transitions/shipped-to-completed") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/orders/$id/transitions/completed-to-cancelled")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

}
