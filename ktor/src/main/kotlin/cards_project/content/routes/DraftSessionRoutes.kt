package cards_project.content.routes

import cards_project.content.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateDraftSession(req: DraftSessionRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.timePerPickSeconds > 0)) errors.add("time_per_pick_positive: validation failed")
    return errors
}

fun Route.draftSessionRoutes() {
    route("/api/draft_sessions") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(DraftSessionRepository.list(skip, limit))
        }
        post {
            val req = call.receive<DraftSessionRequest>()
            val errors = validateDraftSession(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = DraftSessionRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = DraftSessionRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            post("/api/draft-sessions/{id}/start") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement start behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/draft-sessions/{id}/abandon") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement abandon behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/draft-sessions/{id}/complete") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement complete behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/api/draft-sessions/{id}/full") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_full behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/transitions/waitingforplayers-to-drafting") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition WaitingForPlayers → Drafting
                call.respond(HttpStatusCode.OK, mapOf("status" to "Drafting"))
            }
            patch("/transitions/drafting-to-completed") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Drafting → Completed
                call.respond(HttpStatusCode.OK, mapOf("status" to "Completed"))
            }
            patch("/transitions/drafting-to-abandoned") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Drafting → Abandoned
                call.respond(HttpStatusCode.OK, mapOf("status" to "Abandoned"))
            }
            patch("/transitions/waitingforplayers-to-abandoned") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition WaitingForPlayers → Abandoned
                call.respond(HttpStatusCode.OK, mapOf("status" to "Abandoned"))
            }
            patch("/transitions/completed-to-drafting") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Completed → Drafting
                call.respond(HttpStatusCode.OK, mapOf("status" to "Drafting"))
            }
            patch("/transitions/abandoned-to-drafting") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Abandoned → Drafting
                call.respond(HttpStatusCode.OK, mapOf("status" to "Drafting"))
            }
        }
    }
}
