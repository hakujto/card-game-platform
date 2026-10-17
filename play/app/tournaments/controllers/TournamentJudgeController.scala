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
class TournamentJudgeController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(TournamentJudgeRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TournamentJudgeRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TournamentJudge] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(TournamentJudgeRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def delete(id: Long): Action[AnyContent] = Action.async {
    db.run(TournamentJudgeRepository.delete(id)).map {
      case true  => NoContent
      case false => NotFound(Json.obj("error" -> "not found"))
    }
  }

  def promoteToHead(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement promote_to_head behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def remove(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement remove behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
