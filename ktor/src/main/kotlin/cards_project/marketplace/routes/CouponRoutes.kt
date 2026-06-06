package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateCoupon(req: CouponRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.validUntil > req.validFrom)) errors.add("valid_until_after_valid_from: validation failed")
    if (!(req.discountValue > java.math.BigDecimal("0"))) errors.add("discount_value_positive: validation failed")
    return errors
}

fun Route.couponRoutes() {
    route("/api/coupons") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(CouponRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<CouponRequest>()
            val errors = validateCoupon(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = CouponRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = CouponRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            put {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<CouponRequest>()
                val errors = validateCoupon(req)
                if (errors.isNotEmpty()) {
                    call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                    return@put
                }
                val updated = CouponRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<CouponRequest>()
                val updated = CouponRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            get("/valid") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_valid behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/applicable") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_applicable_to_order behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/redeem") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement redeem behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/deactivate") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement deactivate behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
