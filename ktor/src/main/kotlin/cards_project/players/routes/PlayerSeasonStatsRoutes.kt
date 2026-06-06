package cards_project.players.routes

import cards_project.players.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validatePlayerSeasonStats(req: PlayerSeasonStatsRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.wins >= 0)) errors.add("wins_not_negative: validation failed")
    if (!(req.losses >= 0)) errors.add("losses_not_negative: validation failed")
    if (!(req.tournamentWins >= 0)) errors.add("tournament_wins_not_negative: validation failed")
    if (!(req.seasonPoints >= 0)) errors.add("season_points_not_negative: validation failed")
    return errors
}

fun Route.playerSeasonStatsRoutes() {
    route("/api/player_season_statses") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(PlayerSeasonStatsRepository.list(skip, limit))
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = PlayerSeasonStatsRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            get("/api/player-season-stats/{id}/win-rate") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement win_rate behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/api/player-season-stats/{id}/points") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement add_points behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/player-season-stats/{id}/tournament-win") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement record_tournament_win behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
