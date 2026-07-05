package cards_project.players.test

import cards_project.players.model.*
import cards_project.players.routes.*
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

class PlayerRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { playerRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/players")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/players?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/players") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "BRONZE", "is_verified": true, "user_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/players") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "BRONZE", "is_verified": true, "user_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/players/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/players") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "BRONZE", "is_verified": true, "user_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/players/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "BRONZE", "is_verified": true, "user_id": 1}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/players/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
