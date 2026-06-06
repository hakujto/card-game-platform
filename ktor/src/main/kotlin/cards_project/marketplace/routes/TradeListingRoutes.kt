package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateTradeListing(req: TradeListingRequest): List<String> {
    val errors = mutableListOf<String>()
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
                // TODO: implement finalize_auction behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/transitions/pending-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Pending → Active
                call.respond(HttpStatusCode.OK, mapOf("status" to "Active"))
            }
            patch("/transitions/active-to-sold") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Active → Sold
                call.respond(HttpStatusCode.OK, mapOf("status" to "Sold"))
            }
            patch("/transitions/active-to-expired") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Active → Expired
                call.respond(HttpStatusCode.OK, mapOf("status" to "Expired"))
            }
            patch("/transitions/active-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Active → Cancelled
                call.respond(HttpStatusCode.OK, mapOf("status" to "Cancelled"))
            }
            patch("/transitions/sold-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Sold → Active
                call.respond(HttpStatusCode.OK, mapOf("status" to "Active"))
            }
            patch("/transitions/expired-to-active") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Expired → Active
                call.respond(HttpStatusCode.OK, mapOf("status" to "Active"))
            }
        }
    }
}
