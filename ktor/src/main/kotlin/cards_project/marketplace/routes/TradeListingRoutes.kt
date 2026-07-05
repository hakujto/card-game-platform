package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTradeListing(req: TradeListingRequest): List<String> {
    val errors = mutableListOf<String>()
    if ((req.listingType == TradeListingListingTypeType.FIXEDPRICE) && req.askingPrice == null) errors.add("asking_price is required when condition is met")
    return errors
}

fun Route.tradeListingRoutes() {
    route("/api/trade_listings") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(TradeListingRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<TradeListingRequest>()
            val errors = validateTradeListing(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = TradeListingRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TradeListingRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<TradeListingRequest>()
                val item = TradeListingRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = TradeListingRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            post("/api/trade-listings/{id}/close") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement close behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/api/trade-listings/{id}/extend") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement extend behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            delete("/api/trade-listings/{id}/cancel") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@delete call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // @guard: TODO: check guard condition — respond Forbidden if not met
                // TODO: implement cancel behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/api/trade-listings/{id}/expired") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_expired behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/api/trade-listings/{id}/finalize") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin", "seller")) return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for finalize_auction"))
                // TODO: implement finalize_auction behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            val allowedTransitions = mapOf(
                "PENDING" to listOf("ACTIVE"),
                "ACTIVE" to listOf("SOLD", "EXPIRED", "CANCELLED")
            )
            patch("/transitions/pending-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Seller")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Pending -> Active"))
                val item = TradeListingRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("ACTIVE" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Active not allowed"))
                val updated = TradeListingRepository.updateStatus(id, "ACTIVE")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/active-to-sold") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TradeListingRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("SOLD" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Sold not allowed"))
                val updated = TradeListingRepository.updateStatus(id, "SOLD")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/active-to-expired") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = TradeListingRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("EXPIRED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Expired not allowed"))
                val updated = TradeListingRepository.updateStatus(id, "EXPIRED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/active-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Seller", "Admin")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Active -> Cancelled"))
                val item = TradeListingRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("CANCELLED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Cancelled not allowed"))
                val updated = TradeListingRepository.updateStatus(id, "CANCELLED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/sold-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition Sold -> Active is not allowed"))
            }
            patch("/transitions/expired-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition Expired -> Active is not allowed"))
            }
        }
    }
}
