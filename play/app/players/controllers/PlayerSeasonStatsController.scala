package cards_project.players.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.players.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class PlayerSeasonStatsController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: PlayerSeasonStats): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.wins >= 0)) errors += "wins_not_negative: validation failed"
    if (!(data.losses >= 0)) errors += "losses_not_negative: validation failed"
    if (!(data.tournamentWins >= 0)) errors += "tournament_wins_not_negative: validation failed"
    if (!(data.seasonPoints >= 0)) errors += "season_points_not_negative: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(PlayerSeasonStatsRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(PlayerSeasonStatsRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def winRateAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement win_rate behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def addPoints(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement add_points behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def recordTournamentWin(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement record_tournament_win behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
