package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateCardPriceHistory(req: CardPriceHistoryRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!((req.minPrice <= req.avgPrice) && (req.avgPrice <= req.maxPrice))) errors.add("price_bounds_consistent: validation failed")
    if (!(req.volume >= 0)) errors.add("volume_not_negative: validation failed")
    if (!(req.minPrice >= java.math.BigDecimal("0"))) errors.add("prices_not_negative: validation failed")
    return errors
}

fun Route.cardPriceHistoryRoutes() {
    route("/api/card_price_histories") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(CardPriceHistoryRepository.list(skip, limit))
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = CardPriceHistoryRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            get("/api/price-history/{id}/change") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement price_change_percent behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/api/price-history/{id}/spike") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_price_spike behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
