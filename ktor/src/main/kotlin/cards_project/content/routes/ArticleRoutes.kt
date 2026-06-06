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
                val updated = ArticleRepository.update(id, req)
                    ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "not found"))
                call.respond(updated)
            }
            patch {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                val req = call.receive<ArticleRequest>()
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
            patch("/transitions/draft-to-published") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Draft → Published
                call.respond(HttpStatusCode.OK, mapOf("status" to "Published"))
            }
            patch("/transitions/published-to-archived") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Published → Archived
                call.respond(HttpStatusCode.OK, mapOf("status" to "Archived"))
            }
            patch("/transitions/archived-to-draft") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Archived → Draft
                call.respond(HttpStatusCode.OK, mapOf("status" to "Draft"))
            }
            patch("/transitions/published-to-draft") {
                val id = call.parameters["id"]?.toIntOrNull()
                    ?: return@patch call.respond(HttpStatusCode.BadRequest, mapOf("error" to "invalid id"))
                // TODO: validate transition Published → Draft
                call.respond(HttpStatusCode.OK, mapOf("status" to "Draft"))
            }
        }
    }
}
