package cards_project.tournaments.routes

import cards_project.tournaments.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateSeason(req: SeasonRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.endDate > req.startDate)) errors.add("end_date_after_start_date: validation failed")
    return errors
}

fun Route.seasonRoutes() {
    route("/api/seasons") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(SeasonRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<SeasonRequest>()
            val errors = validateSeason(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = SeasonRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = SeasonRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            put {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<SeasonRequest>()
                val errors = validateSeason(req)
                if (errors.isNotEmpty()) {
                    call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                    return@put
                }
                val item = SeasonRepository.findById(id)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = SeasonRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<SeasonRequest>()
                val item = SeasonRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = SeasonRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            post("/activate") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin")) return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for activate"))
                // TODO: implement activate behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/deactivate") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin")) return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for deactivate"))
                // TODO: implement deactivate behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/finalize") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin")) return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for finalize_rewards"))
                // TODO: implement finalize_rewards behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/ongoing") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_ongoing behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
