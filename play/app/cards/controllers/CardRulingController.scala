package cards_project.cards.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.cards.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class CardRulingController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(CardRulingRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(CardRulingRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[CardRuling] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(CardRulingRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def delete(id: Long): Action[AnyContent] = Action.async {
    db.run(CardRulingRepository.delete(id)).map {
      case true  => NoContent
      case false => NotFound(Json.obj("error" -> "not found"))
    }
  }

  def isCurrentAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_current behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def supersedesPreviousAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement supersedes_previous behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
