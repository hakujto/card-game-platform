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

class SeasonRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { seasonRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/seasons")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/seasons?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/seasons") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "start_date": "2024-01-01", "end_date": "2024-12-31", "format": "STANDARD", "is_active": true}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/seasons") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "start_date": "2024-01-01", "end_date": "2024-12-31", "format": "STANDARD", "is_active": true}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/seasons/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/seasons") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "start_date": "2024-01-01", "end_date": "2024-12-31", "format": "STANDARD", "is_active": true}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/seasons/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "start_date": "2024-01-01", "end_date": "2024-12-31", "format": "STANDARD", "is_active": true}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/seasons/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
