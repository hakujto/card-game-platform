package cards_project.content.routes

import cards_project.content.model.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun validateArticle(req: ArticleRequest): List<String> {
    val errors = mutableListOf<String>()
    if (!(req.viewCount >= 0)) errors.add("view_count_not_negative: validation failed")
    if (!(req.likesCount >= 0)) errors.add("likes_count_not_negative: validation failed")
    return errors
}

fun Route.articleRoutes() {
    route("/api/articles") {
        get {
            val skip  = call.request.queryParameters["skip"]?.toIntOrNull() ?: 0
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 100
            val q = call.request.queryParameters["q"]
            call.respond(ArticleRepository.list(skip, limit, q))
        }
        post {
            val req = call.receive<ArticleRequest>()
            val errors = validateArticle(req)
            if (errors.isNotEmpty()) {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                return@post
            }
            val created = ArticleRepository.create(req)
            call.respond(HttpStatusCode.Created, created)
        }
        route("/{id}") {
            get {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val item = ArticleRepository.findById(id)
                    ?: return@get call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(item)
            }
            put {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<ArticleRequest>()
                val errors = validateArticle(req)
                if (errors.isNotEmpty()) {
                    call.respond(HttpStatusCode.BadRequest, mapOf("errors" to errors))
                    return@put
                }
                val item = ArticleRepository.findById(id)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = ArticleRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<ArticleRequest>()
                val item = ArticleRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val updated = ArticleRepository.update(id, req)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            post("/publish") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement publish behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/archive") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement archive behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/view") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement increment_view behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            post("/like") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement like behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            delete("/like") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@delete call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement unlike behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            get("/reading-time") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: implement reading_time_minutes behavior
                call.respond(HttpStatusCode.OK, mapOf("ok" to true))
            }
            val allowedTransitions = mapOf(
                "DRAFT" to listOf("PUBLISHED"),
                "PUBLISHED" to listOf("ARCHIVED"),
                "ARCHIVED" to listOf("DRAFT")
            )
            patch("/transitions/draft-to-published") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Editor", "Admin")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Draft -> Published"))
                val item = ArticleRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("PUBLISHED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Published not allowed"))
                val updated = ArticleRepository.updateStatus(id, "PUBLISHED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/published-to-archived") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Editor", "Admin")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Published -> Archived"))
                val item = ArticleRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("ARCHIVED" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Archived not allowed"))
                val updated = ArticleRepository.updateStatus(id, "ARCHIVED")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/archived-to-draft") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val userRole = call.request.headers["X-User-Role"]
                if (userRole !in listOf("Admin")) return@patch call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Insufficient role for transition Archived -> Draft"))
                val item = ArticleRepository.findById(id)
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                val allowed = allowedTransitions[item.status.name] ?: emptyList()
                if ("DRAFT" !in allowed) return@patch call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition ${item.status.name} -> Draft not allowed"))
                val updated = ArticleRepository.updateStatus(id, "DRAFT")
                    ?: return@patch call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch("/transitions/published-to-draft") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Transition Published -> Draft is not allowed"))
            }
        }
    }
}

// TODO: implement hook update_search_index
fun updateSearchIndex(item: ArticleResponse) {
}
