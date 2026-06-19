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
import cards_project.content.model.ArticleTagTable

object ArticleTagAssignmentTable : IntIdTable("article_tag_assignment") {
    val articleId = reference("article_id", ArticleTable, onDelete = ReferenceOption.CASCADE)
    val tagId = reference("tag_id", ArticleTagTable, onDelete = ReferenceOption.CASCADE)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class ArticleTagAssignmentRequest(
    val articleId: Int,
    val tagId: Int
)

data class ArticleTagAssignmentResponse(
    val id: Int,
    val articleId: Int,
    val tagId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toArticleTagAssignmentResponse() = ArticleTagAssignmentResponse(
    id = this[ArticleTagAssignmentTable.id].value,
    articleId = this[ArticleTagAssignmentTable.articleId].value,
    tagId = this[ArticleTagAssignmentTable.tagId].value,
    createdAt = this[ArticleTagAssignmentTable.createdAt].toString(),
    updatedAt = this[ArticleTagAssignmentTable.updatedAt].toString()
)

object ArticleTagAssignmentRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<ArticleTagAssignmentResponse> = transaction {
        ArticleTagAssignmentTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toArticleTagAssignmentResponse() }
    }

    fun findById(id: Int): ArticleTagAssignmentResponse? = transaction {
        ArticleTagAssignmentTable.selectAll().where { ArticleTagAssignmentTable.id eq id }.singleOrNull()?.toArticleTagAssignmentResponse()
    }

    fun create(req: ArticleTagAssignmentRequest): ArticleTagAssignmentResponse = transaction {
        val inserted = ArticleTagAssignmentTable.insertAndGetId {
            it[articleId] = EntityID(req.articleId, ArticleTable)
            it[tagId] = EntityID(req.tagId, ArticleTagTable)
        }
        ArticleTagAssignmentTable.selectAll().where { ArticleTagAssignmentTable.id eq inserted }.single().toArticleTagAssignmentResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        ArticleTagAssignmentTable.deleteWhere { ArticleTagAssignmentTable.id eq id } > 0
    }

}
