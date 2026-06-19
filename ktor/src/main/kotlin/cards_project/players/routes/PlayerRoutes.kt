package cards_project.players.routes

import cards_project.players.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validatePlayer(req: PlayerRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.peakRating >= req.rating)) errors.add("peak_rating_gte_rating: validation failed")
    if (!(req.displayName != null)) errors.add("display_name_not_empty: validation failed")
    return errors
}

fun Route.playerRoutes() {
    route("/api/players") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(PlayerRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<PlayerRequest>()
            val errors = validatePlayer(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = PlayerRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = PlayerRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<PlayerRequest>()
                val item = PlayerRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = PlayerRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            post("/promote") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement promote behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/demote") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement demote behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/win") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement record_win behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/loss") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement record_loss behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/win-rate") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement win_rate behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/verify") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement verify behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/rating") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement update_rating behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}

// TODO: implement hook initialize_collection
fun initializeCollection(item: PlayerResponse) {
}

// TODO: implement hook update_rank
fun updateRank(item: PlayerResponse) {
}
