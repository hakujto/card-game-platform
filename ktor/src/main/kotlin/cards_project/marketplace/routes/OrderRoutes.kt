package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateOrder(req: OrderRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.total >= java.math.BigDecimal("0"))) errors.add("total_not_negative: validation failed")
    if (!(req.discountApplied <= req.total)) errors.add("discount_not_exceed_total: validation failed")
    return errors
}

fun Route.orderRoutes() {
    route("/api/orders") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            call.respond(OrderRepository.list(skip, limit))
        }
        post {
            val req = call.receive<OrderRequest>()
            val errors = validateOrder(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = OrderRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = OrderRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            delete("/cancel") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@delete call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement cancel behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/pay") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement pay behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/process-payment") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement process_payment behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/total") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement calculate_total behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/discount") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement apply_discount behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/refund") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement refund behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/transitions/pending-to-paid") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Pending → Paid
                call.respond(HttpStatusCode.OK, mapOf("status" to "Paid"))
            }
            patch("/transitions/paid-to-processing") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Paid → Processing
                call.respond(HttpStatusCode.OK, mapOf("status" to "Processing"))
            }
            patch("/transitions/processing-to-shipped") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Processing → Shipped
                call.respond(HttpStatusCode.OK, mapOf("status" to "Shipped"))
            }
            patch("/transitions/shipped-to-completed") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Shipped → Completed
                call.respond(HttpStatusCode.OK, mapOf("status" to "Completed"))
            }
            patch("/transitions/pending-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Pending → Cancelled
                call.respond(HttpStatusCode.OK, mapOf("status" to "Cancelled"))
            }
            patch("/transitions/paid-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Paid → Cancelled
                call.respond(HttpStatusCode.OK, mapOf("status" to "Cancelled"))
            }
            patch("/transitions/completed-to-refunded") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Completed → Refunded
                call.respond(HttpStatusCode.OK, mapOf("status" to "Refunded"))
            }
            patch("/transitions/refunded-to-completed") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Refunded → Completed
                call.respond(HttpStatusCode.OK, mapOf("status" to "Completed"))
            }
            patch("/transitions/completed-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Completed → Cancelled
                call.respond(HttpStatusCode.OK, mapOf("status" to "Cancelled"))
            }
        }
    }
}
