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
            val allowedTransitions = mapOf(
                "OPEN" to listOf("UNDERREVIEW"),
                "UNDERREVIEW" to listOf("RESOLVED", "ESCALATED"),
                "ESCALATED" to listOf("RESOLVED")
            )
            patch("/transitions/open-to-underreview") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Moderator")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Open -> UnderReview"))
                val item = TradeDisputeRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("UNDERREVIEW" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> UnderReview not allowed"))
                val updated = TradeDisputeRepository.updateStatus(id, "UNDERREVIEW")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/underreview-to-resolved") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Moderator")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition UnderReview -> Resolved"))
                val item = TradeDisputeRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("RESOLVED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Resolved not allowed"))
                val updated = TradeDisputeRepository.updateStatus(id, "RESOLVED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/underreview-to-escalated") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition UnderReview -> Escalated"))
                val item = TradeDisputeRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("ESCALATED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Escalated not allowed"))
                val updated = TradeDisputeRepository.updateStatus(id, "ESCALATED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/escalated-to-resolved") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Escalated -> Resolved"))
                val item = TradeDisputeRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("RESOLVED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Resolved not allowed"))
                val updated = TradeDisputeRepository.updateStatus(id, "RESOLVED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/resolved-to-open") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition Resolved -> Open is not allowed"))
            }
        }
    }
}
