package cards_project.content.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class ArticleTagAssignment(
  id: Option[Long] = None,
  articleId: Long,
  tagId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object ArticleTagAssignment {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[ArticleTagAssignment] = Json.format[ArticleTagAssignment]
}

class ArticleTagAssignmentTable(tag: Tag) extends Table[ArticleTagAssignment](tag, "article_tag_assignments") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def articleId = column[Long]("article_id")
  def tagId = column[Long]("tag_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, articleId, tagId, createdAt, updatedAt).mapTo[ArticleTagAssignment]
}

object ArticleTagAssignmentRepository {
  val table = TableQuery[ArticleTagAssignmentTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[ArticleTagAssignment]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[ArticleTagAssignment]] =
    table.filter(_.id === id).result.headOption

  def create(item: ArticleTagAssignment): DBIO[ArticleTagAssignment] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
