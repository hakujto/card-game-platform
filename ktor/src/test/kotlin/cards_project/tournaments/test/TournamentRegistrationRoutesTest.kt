package cards_project.tournaments.test

import cards_project.tournaments.model.*
import cards_project.tournaments.routes.*
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

class TournamentRegistrationRoutesTest {

    private val ownerId = 1
    private val ownerHeaders = mapOf("X-User-Id" to ownerId.toString())

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { tournamentRegistrationRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/tournament_registrations")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/tournament_registrations") {
            contentType(ContentType.Application.Json)
            ownerHeaders.forEach { (k, v) -> header(k, v) }
            setBody("""{"status": "Registered", "points_earned": 1, "registered_at": "2024-01-01T00:00:00", "tournament_id": 1, "player_id": $ownerId, "deck_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/tournament_registrations") {
            contentType(ContentType.Application.Json)
            ownerHeaders.forEach { (k, v) -> header(k, v) }
            setBody("""{"status": "Registered", "points_earned": 1, "registered_at": "2024-01-01T00:00:00", "tournament_id": 1, "player_id": $ownerId, "deck_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/tournament_registrations/$id") {
            ownerHeaders.forEach { (k, v) -> header(k, v) }
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get by id returns 403 for non-owner`() = testApp {
        val created = client.post("/api/tournament_registrations") {
            contentType(ContentType.Application.Json)
            ownerHeaders.forEach { (k, v) -> header(k, v) }
            setBody("""{"status": "Registered", "points_earned": 1, "registered_at": "2024-01-01T00:00:00", "tournament_id": 1, "player_id": $ownerId, "deck_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/tournament_registrations/$id") {
            header("X-User-Id", "9999")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/tournament_registrations/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
