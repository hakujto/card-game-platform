package cards_project.content.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class ArticleComment(
  id: Option[Long] = None,
  body: String,
  isHidden: Boolean = false,
  articleId: Long,
  authorId: Long,
  parentCommentId: Option[Long] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object ArticleComment {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[ArticleComment] = Json.format[ArticleComment]
}

class ArticleCommentTable(tag: Tag) extends Table[ArticleComment](tag, "article_comments") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def body = column[String]("body")
  def isHidden = column[Boolean]("is_hidden")
  def articleId = column[Long]("article_id")
  // cross-context FK to Player (external context — no local table)
  def authorId = column[Long]("author_id")
  def parentCommentId = column[Option[Long]]("parent_comment_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, body, isHidden, articleId, authorId, parentCommentId, createdAt, updatedAt).mapTo[ArticleComment]
}

object ArticleCommentRepository {
  val table = TableQuery[ArticleCommentTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[ArticleComment]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[ArticleComment]] =
    table.filter(_.id === id).result.headOption

  def create(item: ArticleComment): DBIO[ArticleComment] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
