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

class CraftingIngredientRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { craftingIngredientRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/crafting_ingredients")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `create returns 201`() = testApp {
        val r = client.post("/api/crafting_ingredients") {
            contentType(ContentType.Application.Json)
            setBody("""{"quantity": 1, "recipe_id": 1, "card_id": 1}""")
        }
        assertEquals(HttpStatusCode.Created, r.status)
    }

    @Test fun `get by id returns 200`() = testApp {
        val created = client.post("/api/crafting_ingredients") {
            contentType(ContentType.Application.Json)
            setBody("""{"quantity": 1, "recipe_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.get("/api/crafting_ingredients/$id")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `delete returns 204`() = testApp {
        val created = client.post("/api/crafting_ingredients") {
            contentType(ContentType.Application.Json)
            setBody("""{"quantity": 1, "recipe_id": 1, "card_id": 1}""")
        }
        val json = Json.parseToJsonElement(created.bodyAsText()).jsonObject
        val id = json["id"]!!.jsonPrimitive.int
        val r = client.delete("/api/crafting_ingredients/$id")
        assertEquals(HttpStatusCode.NoContent, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/crafting_ingredients/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
