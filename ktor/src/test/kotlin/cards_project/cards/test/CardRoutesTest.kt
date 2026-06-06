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

class CardRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { cardRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/cards")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/cards?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/cards") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/cards") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/cards/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/cards") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/cards/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 1, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": true, "is_restricted": true, "power_level": 1, "set_id": 1}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/cards/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
