package cards_project.cards.routes

import cards_project.cards.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateCard(req: CardRequest): List<String> {
    val errors = mutableListOf<String>()
    if (req.manaCost < 0) errors.add("mana_cost must be >= 0")
    if (req.manaCost > 20) errors.add("mana_cost must be <= 20")
    if (req.powerLevel < 1) errors.add("power_level must be >= 1")
    if (req.powerLevel > 10) errors.add("power_level must be <= 10")
    if ((req.cardType == CardCardTypeType.CREATURE) && req.attack == null) errors.add("attack is required when condition is met")
    if ((req.cardType == CardCardTypeType.CREATURE) && req.defense == null) errors.add("defense is required when condition is met")
    if ((req.cardType == CardCardTypeType.PLANESWALKER) && req.loyalty == null) errors.add("loyalty is required when condition is met")
    return errors
}

fun Route.cardRoutes() {
    route("/api/cards") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(CardRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<CardRequest>()
            val errors = validateCard(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = CardRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = CardRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            put {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<CardRequest>()
                val errors = validateCard(req)
                if (errors.isNotEmpty()) {
                    call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                    return@put
                }
                val item = CardRepository.findById(id)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = CardRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<CardPatchRequest>()
                val item = CardRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = CardRepository.patch(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            post("/ban") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin", "moderator")) return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for ban"))
                // TODO: implement ban behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/unban") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin", "moderator")) return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for unban"))
                // TODO: implement unban behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/restrict") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin", "moderator")) return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for restrict"))
                // TODO: implement restrict behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/unrestrict") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin", "moderator")) return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for unrestrict"))
                // TODO: implement unrestrict behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            put("/replace") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("admin")) return@put call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for replace"))
                // TODO: implement replace behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/value") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement calculate_value behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/rarity-bonus") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement apply_rarity_bonus behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/legal") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement is_legal_in_format behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
        }
    }
}

// TODO: implement hook validate_legality
fun validateLegality(item: CardResponse) {
}

// TODO: implement hook validate_not_in_use
fun validateNotInUse(item: CardResponse) {
}
