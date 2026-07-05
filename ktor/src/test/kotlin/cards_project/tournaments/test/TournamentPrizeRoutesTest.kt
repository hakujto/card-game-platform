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

class TournamentPrizeRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { tournamentPrizeRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/tournament_prizes")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/tournament_prizes") {
            contentType(ContentType.Application.Json)
            setBody("""{"placement_from": 1, "placement_to": 1, "prize_type": "CURRENCY", "amount": 1.00, "season_points": 1, "tournament_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/tournament_prizes") {
            contentType(ContentType.Application.Json)
            setBody("""{"placement_from": 1, "placement_to": 1, "prize_type": "CURRENCY", "amount": 1.00, "season_points": 1, "tournament_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/tournament_prizes/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/tournament_prizes") {
            contentType(ContentType.Application.Json)
            setBody("""{"placement_from": 1, "placement_to": 1, "prize_type": "CURRENCY", "amount": 1.00, "season_points": 1, "tournament_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/tournament_prizes/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"placement_from": 1, "placement_to": 1, "prize_type": "CURRENCY", "amount": 1.00, "season_points": 1, "tournament_id": 1}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `delete returns 204`() = testApp {
        val created = client.post("/api/tournament_prizes") {
            contentType(ContentType.Application.Json)
            setBody("""{"placement_from": 1, "placement_to": 1, "prize_type": "CURRENCY", "amount": 1.00, "season_points": 1, "tournament_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.delete("/api/tournament_prizes/$id") {
        }
        assertEquals(HttpStatusCode.NoContent, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/tournament_prizes/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
