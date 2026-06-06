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

class DeckTagRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { deckTagRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/deck_tags")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/deck_tags?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/deck_tags") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test"}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/deck_tags") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test"}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/deck_tags/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/deck_tags") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test"}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/deck_tags/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test"}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `delete returns 204`() = testApp {
        val created = client.post("/api/deck_tags") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test"}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.delete("/api/deck_tags/$id")
        assertEquals(HttpStatusCode.NoContent, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/deck_tags/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
