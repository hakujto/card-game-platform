package cards_project.players.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait FriendshipStatusType
object FriendshipStatusType {
  case object PENDING extends FriendshipStatusType
  case object ACCEPTED extends FriendshipStatusType
  case object BLOCKED extends FriendshipStatusType
  val values: Seq[FriendshipStatusType] = Seq(PENDING, ACCEPTED, BLOCKED)
  def fromString(s: String): FriendshipStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown FriendshipStatusType: $s"))
  implicit val format: Format[FriendshipStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Friendship(
  id: Option[Long] = None,
  status: String = "PENDING",
  requesterId: Long,
  receiverId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Friendship {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Friendship] = Json.format[Friendship]
}

class FriendshipTable(tag: Tag) extends Table[Friendship](tag, "friendships") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def status = column[String]("status")
  def requesterId = column[Long]("requester_id")
  def receiverId = column[Long]("receiver_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, status, requesterId, receiverId, createdAt, updatedAt).mapTo[Friendship]
}

object FriendshipRepository {
  val table = TableQuery[FriendshipTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Friendship]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[Friendship]] =
    table.filter(_.id === id).result.headOption

  def create(item: Friendship): DBIO[Friendship] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
