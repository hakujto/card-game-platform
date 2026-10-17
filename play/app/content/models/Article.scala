package cards_project.content.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait ArticleStatusType
object ArticleStatusType {
  case object DRAFT extends ArticleStatusType
  case object PUBLISHED extends ArticleStatusType
  case object ARCHIVED extends ArticleStatusType
  val values: Seq[ArticleStatusType] = Seq(DRAFT, PUBLISHED, ARCHIVED)
  def fromString(s: String): ArticleStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown ArticleStatusType: $s"))
  implicit val format: Format[ArticleStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait ArticleArticleTypeType
object ArticleArticleTypeType {
  case object GUIDE extends ArticleArticleTypeType
  case object TIERLIST extends ArticleArticleTypeType
  case object MATCHUP extends ArticleArticleTypeType
  case object NEWS extends ArticleArticleTypeType
  case object SPOTLIGHT extends ArticleArticleTypeType
  case object DECKLIST extends ArticleArticleTypeType
  val values: Seq[ArticleArticleTypeType] = Seq(GUIDE, TIERLIST, MATCHUP, NEWS, SPOTLIGHT, DECKLIST)
  def fromString(s: String): ArticleArticleTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown ArticleArticleTypeType: $s"))
  implicit val format: Format[ArticleArticleTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait ArticleLanguageType
object ArticleLanguageType {
  case object EN extends ArticleLanguageType
  case object DE extends ArticleLanguageType
  case object FR extends ArticleLanguageType
  case object IT extends ArticleLanguageType
  case object ES extends ArticleLanguageType
  case object JP extends ArticleLanguageType
  case object PT extends ArticleLanguageType
  val values: Seq[ArticleLanguageType] = Seq(EN, DE, FR, IT, ES, JP, PT)
  def fromString(s: String): ArticleLanguageType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown ArticleLanguageType: $s"))
  implicit val format: Format[ArticleLanguageType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Article(
  id: Option[Long] = None,
  title: String,
  slug: String,
  body: String,
  excerpt: Option[String] = None,
  coverImageUrl: Option[String] = None,
  status: String = "DRAFT",
  articleType: String = "GUIDE",
  language: String = "EN",
  viewCount: Int = 0,
  likesCount: Int = 0,
  totalViewsAlltime: Long = 0L,
  isFeatured: Boolean = false,
  publishedAt: Option[java.time.LocalDateTime] = None,
  authorId: Long,
  featuredDeckId: Option[Long] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Article {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Article] = Json.format[Article]
}

class ArticleTable(tag: Tag) extends Table[Article](tag, "articles") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def title = column[String]("title")
  def slug = column[String]("slug", O.Unique)
  def body = column[String]("body")
  def excerpt = column[Option[String]]("excerpt")
  def coverImageUrl = column[Option[String]]("cover_image_url")
  def status = column[String]("status")
  def articleType = column[String]("article_type")
  def language = column[String]("language")
  def viewCount = column[Int]("view_count")
  def likesCount = column[Int]("likes_count")
  def totalViewsAlltime = column[Long]("total_views_alltime")
  def isFeatured = column[Boolean]("is_featured")
  def publishedAt = column[Option[LocalDateTime]]("published_at")
  // cross-context FK to Player (external context — no local table)
  def authorId = column[Long]("author_id")
  // cross-context FK to Deck (external context — no local table)
  def featuredDeckId = column[Option[Long]]("featured_deck_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, title, slug, body, excerpt, coverImageUrl, status, articleType, language, viewCount, likesCount, totalViewsAlltime, isFeatured, publishedAt, authorId, featuredDeckId, createdAt, updatedAt).mapTo[Article]
}

object ArticleRepository {
  val table = TableQuery[ArticleTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Article]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.title.like("%" + query + "%") || row.excerpt.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Article]] =
    table.filter(_.id === id).result.headOption

  def create(item: Article): DBIO[Article] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Article)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Article]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def patch(id: Long, fields: Map[String, JsValue])(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Article]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(
          excerpt = fields.get("excerpt").flatMap(_.asOpt[String]).orElse(existing.excerpt),
          coverImageUrl = fields.get("cover_image_url").flatMap(_.asOpt[String]).orElse(existing.coverImageUrl),
          isFeatured = fields.get("is_featured").flatMap(_.asOpt[Boolean]).getOrElse(existing.isFeatured)
        )
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

  def updateStatus(id: Long, newStatus: String)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Article]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(status = newStatus)
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}
