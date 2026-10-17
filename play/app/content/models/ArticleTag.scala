package cards_project.content.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class ArticleTag(
  id: Option[Long] = None,
  name: String,
  slug: String,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object ArticleTag {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[ArticleTag] = Json.format[ArticleTag]
}

class ArticleTagTable(tag: Tag) extends Table[ArticleTag](tag, "article_tags") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def name = column[String]("name")
  def slug = column[String]("slug", O.Unique)
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, name, slug, createdAt, updatedAt).mapTo[ArticleTag]
}

object ArticleTagRepository {
  val table = TableQuery[ArticleTagTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[ArticleTag]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[ArticleTag]] =
    table.filter(_.id === id).result.headOption

  def create(item: ArticleTag): DBIO[ArticleTag] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: ArticleTag)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[ArticleTag]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
