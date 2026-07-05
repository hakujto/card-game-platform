package cards_project.tournaments.routes

import cards_project.tournaments.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateAwardedPrize(req: AwardedPrizeRequest): List<String> {
    val errors = mutableListOf<String>()
    if ((req.claimed == true) && req.claimedAt == null) errors.add("claimed_at is required when condition is met")
    return errors
}

fun Route.awardedPrizeRoutes() {
    route("/api/awarded_prizes") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(AwardedPrizeRepository.list(skip, limit))
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = AwardedPrizeRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            post("/api/awarded-prizes/{id}/claim") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement claim behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
