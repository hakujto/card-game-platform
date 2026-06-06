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

class TournamentRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { tournamentRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/tournaments")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/tournaments?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/tournaments") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 1.00, "prize_pool": 1.00, "start_time": "2024-01-01T00:00:00", "is_online": true, "season_id": 1, "organizer_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/tournaments") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 1.00, "prize_pool": 1.00, "start_time": "2024-01-01T00:00:00", "is_online": true, "season_id": 1, "organizer_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/tournaments/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/tournaments") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 1.00, "prize_pool": 1.00, "start_time": "2024-01-01T00:00:00", "is_online": true, "season_id": 1, "organizer_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/tournaments/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 1, "entry_fee": 1.00, "prize_pool": 1.00, "start_time": "2024-01-01T00:00:00", "is_online": true, "season_id": 1, "organizer_id": 1}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/tournaments/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
