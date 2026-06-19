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

class TradeDisputeRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { tradeDisputeRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/trade_disputes")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "Open", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "Open", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/trade_disputes/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/trade_disputes/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

    @Test fun `transition Open to UnderReview returns 403 for wrong role`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "Open", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/open-to-underreview") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Open to UnderReview returns 200 for allowed role`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "Open", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/open-to-underreview") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition UnderReview to Resolved returns 403 for wrong role`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "UnderReview", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/underreview-to-resolved") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition UnderReview to Resolved returns 200 for allowed role`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "UnderReview", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/underreview-to-resolved") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition UnderReview to Escalated returns 403 for wrong role`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "UnderReview", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/underreview-to-escalated") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition UnderReview to Escalated returns 200 for allowed role`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "UnderReview", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/underreview-to-escalated") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Escalated to Resolved returns 403 for wrong role`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "Escalated", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/escalated-to-resolved") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Escalated to Resolved returns 200 for allowed role`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "Escalated", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/escalated-to-resolved") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Resolved to Open returns 409`() = testApp {
        val created = client.post("/api/trade_disputes") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "Resolved", "reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00", "transaction_id": 1, "opened_by_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/trade_disputes/$id/transitions/resolved-to-open")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

}
