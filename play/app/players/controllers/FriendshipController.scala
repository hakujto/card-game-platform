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
class FriendshipController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(FriendshipRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(FriendshipRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) =>
        // TODO: check ownership: item.requesterId vs X-User-Id header
        Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Friendship] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(FriendshipRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def delete(id: Long): Action[AnyContent] = Action.async {
    db.run(FriendshipRepository.delete(id)).map {
      case true  => NoContent
      case false => NotFound(Json.obj("error" -> "not found"))
    }
  }

  def accept(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement accept behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def decline(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement decline behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def block(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement block behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
