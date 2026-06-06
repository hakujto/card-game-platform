package cards_project.tournaments.routes

import cards_project.tournaments.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateMatch(req: MatchRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!((req.player1Wins >= 0) && (req.player2Wins >= 0))) errors.add("wins_not_negative: validation failed")
    return errors
}

fun Route.matchRoutes() {
    route("/api/matches") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(MatchRepository.list(skip, limit))
        }
        post {
            val req = call.receive<MatchRequest>()
            val errors = validateMatch(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = MatchRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = MatchRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            post("/record") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement record_result behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/finalize") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement finalize_result behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/winner") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement determine_winner behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/concede") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement concede behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/draw") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement draw behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/transitions/pending-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Pending → Active
                call.respond(HttpStatusCode.OK, mapOf("status" to "Active"))
            }
            patch("/transitions/active-to-completed") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Active → Completed
                call.respond(HttpStatusCode.OK, mapOf("status" to "Completed"))
            }
            patch("/transitions/active-to-draw") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Active → Draw
                call.respond(HttpStatusCode.OK, mapOf("status" to "Draw"))
            }
            patch("/transitions/pending-to-bye") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Pending → BYE
                call.respond(HttpStatusCode.OK, mapOf("status" to "BYE"))
            }
            patch("/transitions/completed-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Completed → Active
                call.respond(HttpStatusCode.OK, mapOf("status" to "Active"))
            }
            patch("/transitions/draw-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Draw → Active
                call.respond(HttpStatusCode.OK, mapOf("status" to "Active"))
            }
            patch("/transitions/bye-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition BYE → Active
                call.respond(HttpStatusCode.OK, mapOf("status" to "Active"))
            }
        }
    }
}
