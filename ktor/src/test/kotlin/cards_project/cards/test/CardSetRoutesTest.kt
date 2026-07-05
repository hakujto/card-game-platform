package cards_project.cards.test

import cards_project.cards.model.*
import cards_project.cards.routes.*
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

class CardSetRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { cardSetRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/card_sets")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/card_sets?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/card_sets") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "CORE", "total_cards": 1, "is_rotated": true}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/card_sets") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "CORE", "total_cards": 1, "is_rotated": true}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/card_sets/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/card_sets") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "CORE", "total_cards": 1, "is_rotated": true}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/card_sets/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "CORE", "total_cards": 1, "is_rotated": true}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/card_sets/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
