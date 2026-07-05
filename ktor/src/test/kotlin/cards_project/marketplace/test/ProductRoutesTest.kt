package cards_project.marketplace.test

import cards_project.marketplace.model.*
import cards_project.marketplace.routes.*
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

class ProductRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { productRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/products")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `search returns 200`() = testApp {
        val r = client.get("/api/products?q=test")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/products") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "product_type": "SINGLECARD", "price": 1.00, "stock": 1, "active": true, "discount_percent": 1, "featured": true}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/products") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "product_type": "SINGLECARD", "price": 1.00, "stock": 1, "active": true, "discount_percent": 1, "featured": true}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/products/$id") {
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `update returns 200`() = testApp {
        val created = client.post("/api/products") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "product_type": "SINGLECARD", "price": 1.00, "stock": 1, "active": true, "discount_percent": 1, "featured": true}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.put("/api/products/$id") {
            contentType(ContentType.Application.Json)
            setBody("""{"name": "test", "product_type": "SINGLECARD", "price": 1.00, "stock": 1, "active": true, "discount_percent": 1, "featured": true}""")
        }
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/products/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
