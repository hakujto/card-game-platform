package cards_project.tournaments.routes

import cards_project.tournaments.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTournamentRound(req: TournamentRoundRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.roundNumber > 0)) errors.add("round_number_positive: validation failed")
    if (!(req.timeLimitMinutes > 0)) errors.add("time_limit_positive: validation failed")
    return errors
}

fun Route.tournamentRoundRoutes() {
    route("/api/tournament_rounds") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(TournamentRoundRepository.list(skip, limit))
        }
        post {
            val req = call.receive<TournamentRoundRequest>()
            val errors = validateTournamentRound(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = TournamentRoundRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TournamentRoundRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            post("/api/rounds/{id}/start") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement start behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/rounds/{id}/complete") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement complete behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/rounds/{id}/pairings") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement generate_pairings behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/api/rounds/{id}/time-expired") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_time_expired behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
