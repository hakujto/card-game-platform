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

class MatchRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { matchRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/matches")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/matches/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/matches/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

    @Test fun `transition Pending to Active returns 403 for wrong role`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/matches/$id/transitions/pending-to-active") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Pending to Active returns 200 for allowed role`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/matches/$id/transitions/pending-to-active") {
            header("X-User-Role", "Judge")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Active to Completed returns 403 for wrong role`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/matches/$id/transitions/pending-to-active") { header("X-User-Role", "Judge") }
        val r = client.patch("/api/matches/$id/transitions/active-to-completed") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Active to Completed returns 200 for allowed role`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/matches/$id/transitions/pending-to-active") { header("X-User-Role", "Judge") }
        val r = client.patch("/api/matches/$id/transitions/active-to-completed") {
            header("X-User-Role", "Judge")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Active to Draw returns 403 for wrong role`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/matches/$id/transitions/pending-to-active") { header("X-User-Role", "Judge") }
        val r = client.patch("/api/matches/$id/transitions/active-to-draw") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Active to Draw returns 200 for allowed role`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/matches/$id/transitions/pending-to-active") { header("X-User-Role", "Judge") }
        val r = client.patch("/api/matches/$id/transitions/active-to-draw") {
            header("X-User-Role", "Judge")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Pending to BYE returns 403 for wrong role`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/matches/$id/transitions/pending-to-bye") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Pending to BYE returns 200 for allowed role`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/matches/$id/transitions/pending-to-bye") {
            header("X-User-Role", "Judge")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Completed to Active returns 409`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/matches/$id/transitions/pending-to-active") { header("X-User-Role", "Judge") }
        client.patch("/api/matches/$id/transitions/active-to-completed") { header("X-User-Role", "Judge") }
        val r = client.patch("/api/matches/$id/transitions/completed-to-active")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

    @Test fun `transition Draw to Active returns 409`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/matches/$id/transitions/pending-to-active") { header("X-User-Role", "Judge") }
        client.patch("/api/matches/$id/transitions/active-to-draw") { header("X-User-Role", "Judge") }
        val r = client.patch("/api/matches/$id/transitions/draw-to-active")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

    @Test fun `transition BYE to Active returns 409`() = testApp {
        val created = client.post("/api/matches") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "PENDING", "player1_wins": 1, "player2_wins": 1, "round_id": 1, "player1_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/matches/$id/transitions/pending-to-bye") { header("X-User-Role", "Judge") }
        val r = client.patch("/api/matches/$id/transitions/bye-to-active")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

}
