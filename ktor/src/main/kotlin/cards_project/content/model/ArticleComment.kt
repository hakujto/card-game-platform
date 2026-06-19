package cards_project.content.model

import kotlinx.serialization.Serializable
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.like
import org.jetbrains.exposed.sql.javatime.CurrentDateTime
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.javatime.datetime
import org.jetbrains.exposed.sql.transactions.transaction

import cards_project.content.model.ArticleTable
import cards_project.players.model.*
import cards_project.content.model.ArticleCommentTable

object ArticleCommentTable : IntIdTable("article_comment") {
    val body = text("body")
    val isHidden = bool("is_hidden").default(false)
    val articleId = reference("article_id", ArticleTable, onDelete = ReferenceOption.CASCADE)
    val authorId = reference("author_id", PlayerTable, onDelete = ReferenceOption.RESTRICT)
    val parentCommentId = reference("parent_comment_id", ArticleCommentTable, onDelete = ReferenceOption.SET_NULL).nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class ArticleCommentRequest(
    val body: String,
    val isHidden: Boolean,
    val articleId: Int,
    val authorId: Int,
    val parentCommentId: Int? = null
)

data class ArticleCommentResponse(
    val id: Int,
    val body: String,
    val isHidden: Boolean,
    val articleId: Int,
    val authorId: Int,
    val parentCommentId: Int?,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toArticleCommentResponse() = ArticleCommentResponse(
    id = this[ArticleCommentTable.id].value,
    body = this[ArticleCommentTable.body],
    isHidden = this[ArticleCommentTable.isHidden],
    articleId = this[ArticleCommentTable.articleId].value,
    authorId = this[ArticleCommentTable.authorId].value,
    parentCommentId = this[ArticleCommentTable.parentCommentId]?.value,
    createdAt = this[ArticleCommentTable.createdAt].toString(),
    updatedAt = this[ArticleCommentTable.updatedAt].toString()
)

object ArticleCommentRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<ArticleCommentResponse> = transaction {
        ArticleCommentTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toArticleCommentResponse() }
    }

    fun findById(id: Int): ArticleCommentResponse? = transaction {
        ArticleCommentTable.selectAll().where { ArticleCommentTable.id eq id }.singleOrNull()?.toArticleCommentResponse()
    }

    fun create(req: ArticleCommentRequest): ArticleCommentResponse = transaction {
        val inserted = ArticleCommentTable.insertAndGetId {
            it[body] = req.body
            it[isHidden] = req.isHidden
            it[articleId] = EntityID(req.articleId, ArticleTable)
            it[authorId] = EntityID(req.authorId, PlayerTable)
            req.parentCommentId?.let { v -> it[parentCommentId] = EntityID(v, ArticleCommentTable) }
        }
        ArticleCommentTable.selectAll().where { ArticleCommentTable.id eq inserted }.single().toArticleCommentResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        ArticleCommentTable.deleteWhere { ArticleCommentTable.id eq id } > 0
    }

    fun replies(id: Int): List<ArticleCommentResponse> = transaction {
        ArticleCommentTable.selectAll().where { ArticleCommentTable.parentCommentId eq id }.map { it.toArticleCommentResponse() }
    }

}
