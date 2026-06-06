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

object ArticleTagTable : IntIdTable("article_tag") {
    val name = varchar("name", 255)
    val slug = varchar("slug", 255)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class ArticleTagRequest(
    val name: String,
    val slug: String
)

data class ArticleTagResponse(
    val id: Int,
    val name: String,
    val slug: String,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toArticleTagResponse() = ArticleTagResponse(
    id = this[ArticleTagTable.id].value,
    name = this[ArticleTagTable.name],
    slug = this[ArticleTagTable.slug],
    createdAt = this[ArticleTagTable.createdAt].toString(),
    updatedAt = this[ArticleTagTable.updatedAt].toString()
)

object ArticleTagRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<ArticleTagResponse> = transaction {
        val query = if (q != null) {
            ArticleTagTable.selectAll().where { (ArticleTagTable.name like "%${q}%") }
        } else {
            ArticleTagTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toArticleTagResponse() }
    }

    fun findById(id: Int): ArticleTagResponse? = transaction {
        ArticleTagTable.selectAll().where { ArticleTagTable.id eq id }.singleOrNull()?.toArticleTagResponse()
    }

    fun create(req: ArticleTagRequest): ArticleTagResponse = transaction {
        val inserted = ArticleTagTable.insertAndGetId {
            it[name] = req.name
            it[slug] = req.slug
        }
        ArticleTagTable.selectAll().where { ArticleTagTable.id eq inserted }.single().toArticleTagResponse()
    }

    fun update(id: Int, req: ArticleTagRequest): ArticleTagResponse? = transaction {
        val updated = ArticleTagTable.update({ ArticleTagTable.id eq id }) {
            it[name] = req.name
            it[slug] = req.slug
        }
        if (updated == 0) return@transaction null
        ArticleTagTable.selectAll().where { ArticleTagTable.id eq id }.singleOrNull()?.toArticleTagResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        ArticleTagTable.deleteWhere { ArticleTagTable.id eq id } > 0
    }

}
