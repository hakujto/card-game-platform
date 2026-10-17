package cards_project.tournaments.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.tournaments.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class TournamentRoundController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: TournamentRound): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.roundNumber > 0)) errors += "round_number_positive: validation failed"
    if (!(data.timeLimitMinutes > 0)) errors += "time_limit_positive: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(TournamentRoundRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TournamentRoundRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TournamentRound] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TournamentRoundRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def start(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement start behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def complete(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement complete behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def generatePairings(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement generate_pairings behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isTimeExpiredAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_time_expired behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
