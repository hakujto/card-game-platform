package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTradeTransaction(req: TradeTransactionRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.platformFee <= req.finalPrice)) errors.add("fee_not_exceed_price: validation failed")
    if (!(req.platformFee >= java.math.BigDecimal("0"))) errors.add("fee_not_negative: validation failed")
    if (!(req.finalPrice > java.math.BigDecimal("0"))) errors.add("final_price_positive: validation failed")
    if ((req.status == TradeTransactionStatusType.COMPLETED) && req.completedAt == null) errors.add("completed_at is required when condition is met")
    return errors
}

fun Route.tradeTransactionRoutes() {
    route("/api/trade_transactions") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(TradeTransactionRepository.list(skip, limit))
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TradeTransactionRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            post("/api/transactions/{id}/complete") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement complete behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/transactions/{id}/refund") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement refund behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/transactions/{id}/dispute") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement open_dispute behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/api/transactions/{id}/seller-net") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement seller_net behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
