package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTradeDispute(req: TradeDisputeRequest): List<String> {
    val errors = mutableListOf<String>()
    return errors
}

fun Route.tradeDisputeRoutes() {
    route("/api/trade_disputes") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(TradeDisputeRepository.list(skip, limit))
        }
        post {
            val req = call.receive<TradeDisputeRequest>()
            val errors = validateTradeDispute(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = TradeDisputeRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TradeDisputeRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            post("/api/disputes/{id}/escalate") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement escalate behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/disputes/{id}/resolve") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement resolve behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/disputes/{id}/close") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement close_resolved behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/disputes/{id}/review") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement review behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/transitions/open-to-underreview") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Open → UnderReview
                call.respond(HttpStatusCode.OK, mapOf("status" to "UnderReview"))
            }
            patch("/transitions/underreview-to-resolved") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition UnderReview → Resolved
                call.respond(HttpStatusCode.OK, mapOf("status" to "Resolved"))
            }
            patch("/transitions/underreview-to-escalated") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition UnderReview → Escalated
                call.respond(HttpStatusCode.OK, mapOf("status" to "Escalated"))
            }
            patch("/transitions/escalated-to-resolved") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Escalated → Resolved
                call.respond(HttpStatusCode.OK, mapOf("status" to "Resolved"))
            }
            patch("/transitions/resolved-to-open") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Resolved → Open
                call.respond(HttpStatusCode.OK, mapOf("status" to "Open"))
            }
        }
    }
}
