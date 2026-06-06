package cards_project.tournaments.routes

import cards_project.tournaments.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTournamentPrize(req: TournamentPrizeRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.placementTo >= req.placementFrom)) errors.add("placement_range_valid: validation failed")
    if (!(req.placementFrom > 0)) errors.add("placement_from_positive: validation failed")
    if (!(req.amount >= java.math.BigDecimal("0"))) errors.add("amount_not_negative: validation failed")
    return errors
}

fun Route.tournamentPrizeRoutes() {
    route("/api/tournament_prizes") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(TournamentPrizeRepository.list(skip, limit))
        }
        post {
            val req = call.receive<TournamentPrizeRequest>()
            val errors = validateTournamentPrize(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = TournamentPrizeRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TournamentPrizeRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            put {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<TournamentPrizeRequest>()
                val errors = validateTournamentPrize(req)
                if (errors.isNotEmpty()) {
                    call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                    return@put
                }
                val updated = TournamentPrizeRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<TournamentPrizeRequest>()
                val updated = TournamentPrizeRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            delete {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@delete call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val deleted = TournamentPrizeRepository.delete(id)
                if (!deleted) return@delete call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(HttpStatusCode.NoContent)
            }
            get("/api/prizes/{id}/applies") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement applies_to_placement behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/prizes/{id}/award") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement award_to_player behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
