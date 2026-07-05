package cards_project.content.test

import cards_project.content.model.*
import cards_project.content.routes.*
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

class DraftSessionRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { draftSessionRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/draft_sessions")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/draft_sessions/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/draft_sessions/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

    @Test fun `transition WaitingForPlayers to Drafting returns 200`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/draft_sessions/$id/transitions/waitingforplayers-to-drafting")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Drafting to Completed returns 200`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/draft_sessions/$id/transitions/waitingforplayers-to-drafting")
        val r = client.patch("/api/draft_sessions/$id/transitions/drafting-to-completed")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Drafting to Abandoned returns 403 for wrong role`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/draft_sessions/$id/transitions/waitingforplayers-to-drafting")
        val r = client.patch("/api/draft_sessions/$id/transitions/drafting-to-abandoned") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition Drafting to Abandoned returns 200 for allowed role`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/draft_sessions/$id/transitions/waitingforplayers-to-drafting")
        val r = client.patch("/api/draft_sessions/$id/transitions/drafting-to-abandoned") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition WaitingForPlayers to Abandoned returns 403 for wrong role`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/draft_sessions/$id/transitions/waitingforplayers-to-abandoned") {
            header("X-User-Role", "nobody")
        }
        assertEquals(HttpStatusCode.Forbidden, r.status)
    }

    @Test fun `transition WaitingForPlayers to Abandoned returns 200 for allowed role`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.patch("/api/draft_sessions/$id/transitions/waitingforplayers-to-abandoned") {
            header("X-User-Role", "Admin")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `transition Completed to Drafting returns 409`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/draft_sessions/$id/transitions/waitingforplayers-to-drafting")
        client.patch("/api/draft_sessions/$id/transitions/drafting-to-completed")
        val r = client.patch("/api/draft_sessions/$id/transitions/completed-to-drafting")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

    @Test fun `transition Abandoned to Drafting returns 409`() = testApp {
        val created = client.post("/api/draft_sessions") {
            contentType(ContentType.Application.Json)
            setBody("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        client.patch("/api/draft_sessions/$id/transitions/waitingforplayers-to-abandoned") { header("X-User-Role", "Admin") }
        val r = client.patch("/api/draft_sessions/$id/transitions/abandoned-to-drafting")
        assertEquals(HttpStatusCode.Conflict, r.status)
    }

}
