package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait TournamentRegistrationStatusType
object TournamentRegistrationStatusType {
  case object REGISTERED extends TournamentRegistrationStatusType
  case object WAITLISTED extends TournamentRegistrationStatusType
  case object WITHDRAWN extends TournamentRegistrationStatusType
  case object DISQUALIFIED extends TournamentRegistrationStatusType
  val values: Seq[TournamentRegistrationStatusType] = Seq(REGISTERED, WAITLISTED, WITHDRAWN, DISQUALIFIED)
  def fromString(s: String): TournamentRegistrationStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TournamentRegistrationStatusType: $s"))
  implicit val format: Format[TournamentRegistrationStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class TournamentRegistration(
  id: Option[Long] = None,
  status: String = "REGISTERED",
  seed: Option[Int] = None,
  finalStanding: Option[Int] = None,
  pointsEarned: Int = 0,
  registeredAt: java.time.LocalDateTime,
  tournamentId: Long,
  playerId: Long,
  deckId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object TournamentRegistration {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TournamentRegistration] = Json.format[TournamentRegistration]
}

class TournamentRegistrationTable(tag: Tag) extends Table[TournamentRegistration](tag, "tournament_registrations") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def status = column[String]("status")
  def seed = column[Option[Int]]("seed")
  def finalStanding = column[Option[Int]]("final_standing")
  def pointsEarned = column[Int]("points_earned")
  def registeredAt = column[LocalDateTime]("registered_at")
  def tournamentId = column[Long]("tournament_id")
  // cross-context FK to Player (external context — no local table)
  def playerId = column[Long]("player_id")
  // cross-context FK to Deck (external context — no local table)
  def deckId = column[Long]("deck_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, status, seed, finalStanding, pointsEarned, registeredAt, tournamentId, playerId, deckId, createdAt, updatedAt).mapTo[TournamentRegistration]
}

object TournamentRegistrationRepository {
  val table = TableQuery[TournamentRegistrationTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[TournamentRegistration]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[TournamentRegistration]] =
    table.filter(_.id === id).result.headOption

  def create(item: TournamentRegistration): DBIO[TournamentRegistration] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

}
