package cards_project.players.routes

import cards_project.players.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.craftingIngredientRoutes() {
    route("/api/crafting_ingredients") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(CraftingIngredientRepository.list(skip, limit))
        }
        post {
            val req = call.receive<CraftingIngredientRequest>()
            val created = CraftingIngredientRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = CraftingIngredientRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            delete {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@delete call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val deleted = CraftingIngredientRepository.delete(id)
                if (!deleted) return@delete call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(HttpStatusCode.NoContent)
            }
        }
    }
}
