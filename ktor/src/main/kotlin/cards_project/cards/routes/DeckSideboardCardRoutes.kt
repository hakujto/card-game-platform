package cards_project.cards.routes

import cards_project.cards.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateDeckSideboardCard(req: DeckSideboardCardRequest): List<String> {
    val errors = mutableListOf<String>()
    return errors
}

fun Route.deckSideboardCardRoutes() {
    route("/api/deck_sideboard_cards") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(DeckSideboardCardRepository.list(skip, limit))
        }
        post {
            val req = call.receive<DeckSideboardCardRequest>()
            val errors = validateDeckSideboardCard(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = DeckSideboardCardRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = DeckSideboardCardRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<DeckSideboardCardRequest>()
                val updated = DeckSideboardCardRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            delete {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@delete call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val deleted = DeckSideboardCardRepository.delete(id)
                if (!deleted) return@delete call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(HttpStatusCode.NoContent)
            }
            patch("/api/sideboard-cards/{id}/increment") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement increment behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/api/sideboard-cards/{id}/decrement") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement decrement behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
