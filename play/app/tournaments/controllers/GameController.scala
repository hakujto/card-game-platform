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
class GameController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Game): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (data.gameNumber < 1) errors += "game_number must be >= 1"
    if (data.gameNumber > 3) errors += "game_number must be <= 3"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(GameRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(GameRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Game] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(GameRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def recordWinner(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement record_winner behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def durationMinutesAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement duration_minutes behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
