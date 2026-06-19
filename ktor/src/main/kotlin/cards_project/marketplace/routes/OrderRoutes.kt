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
                val userId = call.request.headers["X-User-Id"]
                if (item.playerId.toString() != userId) return@get call.respond(HttpStatusCode.Forbidden, mapOf("error" to "You do not own this resource."))
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
                // @guard: TODO: check guard condition — respond Forbidden if not met
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
            val allowedTransitions = mapOf(
                "PENDING" to listOf("PAID", "CANCELLED"),
                "PAID" to listOf("PROCESSING", "CANCELLED"),
                "PROCESSING" to listOf("SHIPPED"),
                "SHIPPED" to listOf("COMPLETED"),
                "COMPLETED" to listOf("REFUNDED")
            )
            patch("/transitions/pending-to-paid") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = OrderRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("PAID" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Paid not allowed"))
                val updated = OrderRepository.updateStatus(id, "PAID")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/paid-to-processing") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Staff")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Paid -> Processing"))
                val item = OrderRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("PROCESSING" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Processing not allowed"))
                val updated = OrderRepository.updateStatus(id, "PROCESSING")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/processing-to-shipped") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Staff")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Processing -> Shipped"))
                val item = OrderRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("SHIPPED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Shipped not allowed"))
                val updated = OrderRepository.updateStatus(id, "SHIPPED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/shipped-to-completed") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Staff")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Shipped -> Completed"))
                val item = OrderRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("COMPLETED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Completed not allowed"))
                val updated = OrderRepository.updateStatus(id, "COMPLETED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/pending-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = OrderRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("CANCELLED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Cancelled not allowed"))
                val updated = OrderRepository.updateStatus(id, "CANCELLED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/paid-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin", "Staff")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Paid -> Cancelled"))
                val item = OrderRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("CANCELLED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Cancelled not allowed"))
                val updated = OrderRepository.updateStatus(id, "CANCELLED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/completed-to-refunded") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Completed -> Refunded"))
                val item = OrderRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("REFUNDED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Refunded not allowed"))
                val updated = OrderRepository.updateStatus(id, "REFUNDED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/refunded-to-completed") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition Refunded -> Completed is not allowed"))
            }
            patch("/transitions/completed-to-cancelled") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition Completed -> Cancelled is not allowed"))
            }
        }
    }
}

// TODO: implement hook assign_currency_default
fun assignCurrencyDefault(item: OrderResponse) {
}

// TODO: implement hook notify_status_change
fun notifyStatusChange(item: OrderResponse) {
}
