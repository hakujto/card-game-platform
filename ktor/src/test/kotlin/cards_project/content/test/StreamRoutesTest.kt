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

class StreamRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { streamRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/streams")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/streams?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/streams") {
            contentType(ContentType.Application.Json)
            setBody("""{"title": "test", "stream_url": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "is_official": true, "viewer_count_peak": 1, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/streams") {
            contentType(ContentType.Application.Json)
            setBody("""{"title": "test", "stream_url": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "is_official": true, "viewer_count_peak": 1, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/streams/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/streams") {
            contentType(ContentType.Application.Json)
            setBody("""{"title": "test", "stream_url": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "is_official": true, "viewer_count_peak": 1, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/streams/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"title": "test", "stream_url": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "is_official": true, "viewer_count_peak": 1, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": 1}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/streams/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
