package cards_project.tournaments.routes

import cards_project.tournaments.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTournament(req: TournamentRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.entryFee >= java.math.BigDecimal("0"))) errors.add("entry_fee_not_negative: validation failed")
    if (!(req.prizePool >= java.math.BigDecimal("0"))) errors.add("prize_pool_not_negative: validation failed")
    return errors
}

fun Route.tournamentRoutes() {
    route("/api/tournaments") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(TournamentRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<TournamentRequest>()
            val errors = validateTournament(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = TournamentRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TournamentRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            put {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<TournamentRequest>()
                val errors = validateTournament(req)
                if (errors.isNotEmpty()) {
                    call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                    return@put
                }
                val item = TournamentRepository.findById(id)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = TournamentRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<TournamentRequest>()
                val item = TournamentRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = TournamentRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            post("/start") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement start behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/cancel") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement cancel behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/complete") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement complete behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/rounds") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement generate_round behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/prizes") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement calculate_prize_distribution behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/register") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement register_player behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/full") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_full behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            val allowedTransitions = mapOf(
                "DRAFT" to listOf("REGISTRATION"),
                "REGISTRATION" to listOf("ONGOING", "CANCELLED"),
                "ONGOING" to listOf("COMPLETED", "CANCELLED")
            )
            patch("/transitions/draft-to-registration") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Organizer")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Draft -> Registration"))
                val item = TournamentRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("REGISTRATION" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Registration not allowed"))
                val updated = TournamentRepository.updateStatus(id, "REGISTRATION")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/registration-to-ongoing") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Organizer")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Registration -> Ongoing"))
                val item = TournamentRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("ONGOING" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Ongoing not allowed"))
                val updated = TournamentRepository.updateStatus(id, "ONGOING")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/registration-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Organizer")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Registration -> Cancelled"))
                val item = TournamentRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("CANCELLED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Cancelled not allowed"))
                val updated = TournamentRepository.updateStatus(id, "CANCELLED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/ongoing-to-completed") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Organizer")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Ongoing -> Completed"))
                val item = TournamentRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("COMPLETED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Completed not allowed"))
                val updated = TournamentRepository.updateStatus(id, "COMPLETED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/ongoing-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Ongoing -> Cancelled"))
                val item = TournamentRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("CANCELLED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Cancelled not allowed"))
                val updated = TournamentRepository.updateStatus(id, "CANCELLED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/completed-to-draft") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition Completed -> Draft is not allowed"))
            }
            patch("/transitions/cancelled-to-draft") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition Cancelled -> Draft is not allowed"))
            }
        }
    }
}

// TODO: implement hook sync_season_stats
fun syncSeasonStats(item: TournamentResponse) {
}

// TODO: implement hook prevent_delete_if_ongoing
fun preventDeleteIfOngoing(item: TournamentResponse) {
}
