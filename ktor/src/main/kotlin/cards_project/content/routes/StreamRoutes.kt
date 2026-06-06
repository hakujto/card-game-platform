package cards_project.content.routes

import cards_project.content.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateStream(req: StreamRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.viewerCountPeak >= 0)) errors.add("viewer_count_not_negative: validation failed")
    return errors
}

fun Route.streamRoutes() {
    route("/api/streams") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(StreamRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<StreamRequest>()
            val errors = validateStream(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = StreamRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = StreamRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            put {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<StreamRequest>()
                val errors = validateStream(req)
                if (errors.isNotEmpty()) {
                    call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                    return@put
                }
                val updated = StreamRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<StreamRequest>()
                val updated = StreamRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            post("/live") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement go_live behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/end") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement end behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/viewers") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement update_viewer_peak behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/duration") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement duration_minutes behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/transitions/scheduled-to-live") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Scheduled → Live
                call.respond(HttpStatusCode.OK, mapOf("status" to "Live"))
            }
            patch("/transitions/live-to-ended") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Live → Ended
                call.respond(HttpStatusCode.OK, mapOf("status" to "Ended"))
            }
            patch("/transitions/ended-to-live") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Ended → Live
                call.respond(HttpStatusCode.OK, mapOf("status" to "Live"))
            }
        }
    }
}
