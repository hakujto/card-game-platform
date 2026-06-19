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

import cards_project.players.model.*
import cards_project.cards.model.*

enum class ArticleStatusType {
    DRAFT, PUBLISHED, ARCHIVED
}

enum class ArticleArticleTypeType {
    GUIDE, TIERLIST, MATCHUP, NEWS, SPOTLIGHT, DECKLIST
}

enum class ArticleLanguageType {
    EN, DE, FR, IT, ES, JP, PT
}

object ArticleTable : IntIdTable("article") {
    val title = varchar("title", 255)
    val slug = varchar("slug", 255).uniqueIndex()
    val body = text("body")
    val excerpt = text("excerpt").nullable()
    val coverImageUrl = text("cover_image_url").nullable()
    val status = enumerationByName<ArticleStatusType>("status", 50).default(ArticleStatusType.DRAFT)
    val articleType = enumerationByName<ArticleArticleTypeType>("article_type", 50).default(ArticleArticleTypeType.GUIDE)
    val language = enumerationByName<ArticleLanguageType>("language", 50).default(ArticleLanguageType.EN)
    val viewCount = integer("view_count").default(0)
    val likesCount = integer("likes_count").default(0)
    val isFeatured = bool("is_featured").default(false)
    val publishedAt = datetime("published_at").nullable()
    val authorId = reference("author_id", PlayerTable, onDelete = ReferenceOption.RESTRICT)
    val featuredDeckId = reference("featured_deck_id", DeckTable, onDelete = ReferenceOption.SET_NULL).nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class ArticleRequest(
    val title: String,
    val slug: String,
    val body: String,
    val excerpt: String? = null,
    val coverImageUrl: String? = null,
    val status: ArticleStatusType,
    val articleType: ArticleArticleTypeType,
    val language: ArticleLanguageType,
    val viewCount: Int,
    val likesCount: Int,
    val isFeatured: Boolean,
    val publishedAt: java.time.LocalDateTime? = null,
    val authorId: Int,
    val featuredDeckId: Int? = null
)

data class ArticleResponse(
    val id: Int,
    val title: String,
    val slug: String,
    val body: String,
    val excerpt: String? = null,
    val coverImageUrl: String? = null,
    val status: ArticleStatusType,
    val articleType: ArticleArticleTypeType,
    val language: ArticleLanguageType,
    val viewCount: Int,
    val likesCount: Int,
    val isFeatured: Boolean,
    val publishedAt: java.time.LocalDateTime? = null,
    val authorId: Int,
    val featuredDeckId: Int?,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toArticleResponse() = ArticleResponse(
    id = this[ArticleTable.id].value,
    title = this[ArticleTable.title],
    slug = this[ArticleTable.slug],
    body = this[ArticleTable.body],
    excerpt = this[ArticleTable.excerpt],
    coverImageUrl = this[ArticleTable.coverImageUrl],
    status = this[ArticleTable.status],
    articleType = this[ArticleTable.articleType],
    language = this[ArticleTable.language],
    viewCount = this[ArticleTable.viewCount],
    likesCount = this[ArticleTable.likesCount],
    isFeatured = this[ArticleTable.isFeatured],
    publishedAt = this[ArticleTable.publishedAt],
    authorId = this[ArticleTable.authorId].value,
    featuredDeckId = this[ArticleTable.featuredDeckId]?.value,
    createdAt = this[ArticleTable.createdAt].toString(),
    updatedAt = this[ArticleTable.updatedAt].toString()
)

object ArticleRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<ArticleResponse> = transaction {
        val query = if (q != null) {
            ArticleTable.selectAll().where { (ArticleTable.title like "%${q}%") or (ArticleTable.excerpt like "%${q}%") }
        } else {
            ArticleTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toArticleResponse() }
    }

    fun findById(id: Int): ArticleResponse? = transaction {
        ArticleTable.selectAll().where { ArticleTable.id eq id }.singleOrNull()?.toArticleResponse()
    }

    fun create(req: ArticleRequest): ArticleResponse = transaction {
        val inserted = ArticleTable.insertAndGetId {
            it[title] = req.title
            it[slug] = req.slug
            it[body] = req.body
            it[excerpt] = req.excerpt
            it[coverImageUrl] = req.coverImageUrl
            it[status] = req.status
            it[articleType] = req.articleType
            it[language] = req.language
            it[viewCount] = req.viewCount
            it[likesCount] = req.likesCount
            it[isFeatured] = req.isFeatured
            it[publishedAt] = req.publishedAt
            it[authorId] = EntityID(req.authorId, PlayerTable)
            req.featuredDeckId?.let { v -> it[featuredDeckId] = EntityID(v, DeckTable) }
        }
        ArticleTable.selectAll().where { ArticleTable.id eq inserted }.single().toArticleResponse()
    }

    fun update(id: Int, req: ArticleRequest): ArticleResponse? = transaction {
        val updated = ArticleTable.update({ ArticleTable.id eq id }) {
            it[title] = req.title
            it[slug] = req.slug
            it[body] = req.body
            it[excerpt] = req.excerpt
            it[coverImageUrl] = req.coverImageUrl
            it[status] = req.status
            it[articleType] = req.articleType
            it[language] = req.language
            it[viewCount] = req.viewCount
            it[likesCount] = req.likesCount
            it[isFeatured] = req.isFeatured
            it[publishedAt] = req.publishedAt
            it[authorId] = EntityID(req.authorId, PlayerTable)
            req.featuredDeckId?.let { v -> it[featuredDeckId] = EntityID(v, DeckTable) }
        }
        if (updated == 0) return@transaction null
        ArticleTable.selectAll().where { ArticleTable.id eq id }.singleOrNull()?.toArticleResponse()
    }

    fun updateStatus(id: Int, newStatus: String): ArticleResponse? = transaction {
        val updated = ArticleTable.update({ ArticleTable.id eq id }) {
            it[status] = ArticleStatusType.valueOf(newStatus)
        }
        if (updated == 0) return@transaction null
        ArticleTable.selectAll().where { ArticleTable.id eq id }.singleOrNull()?.toArticleResponse()
    }

    fun tagAssignments(id: Int): List<ArticleTagAssignmentResponse> = transaction {
        ArticleTagAssignmentTable.selectAll().where { ArticleTagAssignmentTable.articleId eq id }.map { it.toArticleTagAssignmentResponse() }
    }

    fun comments(id: Int): List<ArticleCommentResponse> = transaction {
        ArticleCommentTable.selectAll().where { ArticleCommentTable.articleId eq id }.map { it.toArticleCommentResponse() }
    }

}
