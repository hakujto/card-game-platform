package cards_project.content.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait StreamStatusType
object StreamStatusType {
  case object SCHEDULED extends StreamStatusType
  case object LIVE extends StreamStatusType
  case object ENDED extends StreamStatusType
  val values: Seq[StreamStatusType] = Seq(SCHEDULED, LIVE, ENDED)
  def fromString(s: String): StreamStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown StreamStatusType: $s"))
  implicit val format: Format[StreamStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait StreamPlatformType
object StreamPlatformType {
  case object TWITCH extends StreamPlatformType
  case object YOUTUBE extends StreamPlatformType
  case object KICKSTREAM extends StreamPlatformType
  case object PLATFORM extends StreamPlatformType
  val values: Seq[StreamPlatformType] = Seq(TWITCH, YOUTUBE, KICKSTREAM, PLATFORM)
  def fromString(s: String): StreamPlatformType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown StreamPlatformType: $s"))
  implicit val format: Format[StreamPlatformType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait StreamLanguageType
object StreamLanguageType {
  case object EN extends StreamLanguageType
  case object DE extends StreamLanguageType
  case object FR extends StreamLanguageType
  case object IT extends StreamLanguageType
  case object ES extends StreamLanguageType
  case object JP extends StreamLanguageType
  case object PT extends StreamLanguageType
  val values: Seq[StreamLanguageType] = Seq(EN, DE, FR, IT, ES, JP, PT)
  def fromString(s: String): StreamLanguageType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown StreamLanguageType: $s"))
  implicit val format: Format[StreamLanguageType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Stream(
  id: Option[Long] = None,
  title: String,
  streamUrl: String,
  status: String = "SCHEDULED",
  platform: String = "TWITCH",
  language: String = "EN",
  isOfficial: Boolean = false,
  viewerCountPeak: Int = 0,
  scheduledStart: java.time.LocalDateTime,
  actualStart: Option[java.time.LocalDateTime] = None,
  endedAt: Option[java.time.LocalDateTime] = None,
  vodUrl: Option[String] = None,
  tournamentId: Option[Long] = None,
  streamerId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Stream {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Stream] = Json.format[Stream]
}

class StreamTable(tag: Tag) extends Table[Stream](tag, "streams") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def title = column[String]("title")
  def streamUrl = column[String]("stream_url")
  def status = column[String]("status")
  def platform = column[String]("platform")
  def language = column[String]("language")
  def isOfficial = column[Boolean]("is_official")
  def viewerCountPeak = column[Int]("viewer_count_peak")
  def scheduledStart = column[LocalDateTime]("scheduled_start")
  def actualStart = column[Option[LocalDateTime]]("actual_start")
  def endedAt = column[Option[LocalDateTime]]("ended_at")
  def vodUrl = column[Option[String]]("vod_url")
  // cross-context FK to Tournament (external context — no local table)
  def tournamentId = column[Option[Long]]("tournament_id")
  // cross-context FK to Player (external context — no local table)
  def streamerId = column[Long]("streamer_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, title, streamUrl, status, platform, language, isOfficial, viewerCountPeak, scheduledStart, actualStart, endedAt, vodUrl, tournamentId, streamerId, createdAt, updatedAt).mapTo[Stream]
}

object StreamRepository {
  val table = TableQuery[StreamTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Stream]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.title.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Stream]] =
    table.filter(_.id === id).result.headOption

  def create(item: Stream): DBIO[Stream] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Stream)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Stream]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def updateStatus(id: Long, newStatus: String)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Stream]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(status = newStatus)
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}
