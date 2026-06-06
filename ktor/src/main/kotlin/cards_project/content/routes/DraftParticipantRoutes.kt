package cards_project.content.routes

import cards_project.content.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateDraftParticipant(req: DraftParticipantRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.seatNumber > 0)) errors.add("seat_number_positive: validation failed")
    return errors
}

fun Route.draftParticipantRoutes() {
    route("/api/draft_participants") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(DraftParticipantRepository.list(skip, limit))
        }
        post {
            val req = call.receive<DraftParticipantRequest>()
            val errors = validateDraftParticipant(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = DraftParticipantRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = DraftParticipantRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            post("/api/draft-participants/{id}/pick") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement pick_card behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/api/draft-participants/{id}/card-count") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement drafted_card_count behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
