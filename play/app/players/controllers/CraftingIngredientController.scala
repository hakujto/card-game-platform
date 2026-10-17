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
class CraftingIngredientController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(CraftingIngredientRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(CraftingIngredientRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[CraftingIngredient] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(CraftingIngredientRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def delete(id: Long): Action[AnyContent] = Action.async {
    db.run(CraftingIngredientRepository.delete(id)).map {
      case true  => NoContent
      case false => NotFound(Json.obj("error" -> "not found"))
    }
  }

}
