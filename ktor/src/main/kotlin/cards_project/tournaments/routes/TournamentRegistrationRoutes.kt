package cards_project.tournaments.routes

import cards_project.tournaments.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTournamentRegistration(req: TournamentRegistrationRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.pointsEarned >= 0)) errors.add("points_earned_not_negative: validation failed")
    return errors
}

fun Route.tournamentRegistrationRoutes() {
    route("/api/tournament_registrations") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(TournamentRegistrationRepository.list(skip, limit))
        }
        post {
            val req = call.receive<TournamentRegistrationRequest>()
            val errors = validateTournamentRegistration(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = TournamentRegistrationRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TournamentRegistrationRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val userId = call.request.headers["X-User-Id"]
                if (item.playerId.toString() != userId) return@get call.respond(HttpStatusCode.Forbidden, mapOf("error" to "You do not own this resource."))
                call.respond(item)
            }
            post("/api/registrations/{id}/withdraw") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement withdraw behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/registrations/{id}/disqualify") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement disqualify behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/registrations/{id}/promote") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement promote_from_waitlist behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
