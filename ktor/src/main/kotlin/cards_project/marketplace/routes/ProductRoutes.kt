package cards_project.marketplace.routes

import cards_project.marketplace.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateProduct(req: ProductRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.price > java.math.BigDecimal("0"))) errors.add("price_positive: validation failed")
    if (!(req.stock >= 0)) errors.add("stock_not_negative: validation failed")
    return errors
}

fun Route.productRoutes() {
    route("/api/products") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(ProductRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<ProductRequest>()
            val errors = validateProduct(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = ProductRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = ProductRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            put {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<ProductRequest>()
                val errors = validateProduct(req)
                if (errors.isNotEmpty()) {
                    call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                    return@put
                }
                val updated = ProductRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<ProductRequest>()
                val updated = ProductRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            post("/activate") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement activate behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/deactivate") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement deactivate behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            patch("/discount") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement apply_discount behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/restock") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement restock behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/effective-price") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement effective_price behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/in-stock") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_in_stock behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}
