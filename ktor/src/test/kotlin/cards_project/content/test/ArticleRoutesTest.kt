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

class ArticleRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { articleRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/articles")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/articles?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/articles") {
            contentType(ContentType.Application.Json)
            setBody("""{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "is_featured": true, "author_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/articles") {
            contentType(ContentType.Application.Json)
            setBody("""{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "is_featured": true, "author_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/articles/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/articles") {
            contentType(ContentType.Application.Json)
            setBody("""{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "is_featured": true, "author_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/articles/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 1, "likes_count": 1, "is_featured": true, "author_id": 1}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/articles/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
