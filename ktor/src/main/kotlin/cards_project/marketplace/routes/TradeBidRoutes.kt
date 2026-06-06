package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTradeBid(req: TradeBidRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.amount > java.math.BigDecimal("0"))) errors.add("amount_positive: validation failed")
    return errors
}

fun Route.tradeBidRoutes() {
    route("/api/trade_bids") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(TradeBidRepository.list(skip, limit))
        }
        post {
            val req = call.receive<TradeBidRequest>()
            val errors = validateTradeBid(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = TradeBidRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TradeBidRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            get("/api/bids/{id}/outbid") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement outbid_by behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            delete("/api/bids/{id}") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@delete call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement retract behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
