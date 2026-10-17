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
class PlayerCollectionController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: PlayerCollection): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.quantity > 0)) errors += "quantity_positive: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(PlayerCollectionRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(PlayerCollectionRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) =>
        // TODO: check ownership: item.playerId vs X-User-Id header
        Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[PlayerCollection] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(PlayerCollectionRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[PlayerCollection] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(PlayerCollectionRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def delete(id: Long): Action[AnyContent] = Action.async {
    db.run(PlayerCollectionRepository.delete(id)).map {
      case true  => NoContent
      case false => NotFound(Json.obj("error" -> "not found"))
    }
  }

  def add(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement add behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def remove(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement remove behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def estimatedValueAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement estimated_value behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
