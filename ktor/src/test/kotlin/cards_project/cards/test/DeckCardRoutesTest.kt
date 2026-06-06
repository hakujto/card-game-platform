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

class DeckCardRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { deckCardRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/deck_cards")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/deck_cards") {
            contentType(ContentType.Application.Json)
            setBody("""{"quantity": 1, "is_commander": true, "deck_id": 1, "card_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/deck_cards") {
            contentType(ContentType.Application.Json)
            setBody("""{"quantity": 1, "is_commander": true, "deck_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/deck_cards/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/deck_cards") {
            contentType(ContentType.Application.Json)
            setBody("""{"quantity": 1, "is_commander": true, "deck_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/deck_cards/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"quantity": 1, "is_commander": true, "deck_id": 1, "card_id": 1}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `delete returns 204`() = testApp {
        val created = client.post("/api/deck_cards") {
            contentType(ContentType.Application.Json)
            setBody("""{"quantity": 1, "is_commander": true, "deck_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.delete("/api/deck_cards/$id")
        assertEquals(HttpStatusCode.NoContent, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/deck_cards/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
