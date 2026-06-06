package cards_project.cards.routes

import cards_project.cards.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.cardRulingRoutes() {
    route("/api/card_rulings") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(CardRulingRepository.list(skip, limit))
        }
        post {
            val req = call.receive<CardRulingRequest>()
            val created = CardRulingRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = CardRulingRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            delete {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@delete call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val deleted = CardRulingRepository.delete(id)
                if (!deleted) return@delete call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(HttpStatusCode.NoContent)
            }
            get("/api/card-rulings/{id}/current") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_current behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/api/card-rulings/{id}/supersedes") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement supersedes_previous behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
