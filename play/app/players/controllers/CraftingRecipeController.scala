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
class CraftingRecipeController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: CraftingRecipe): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.dustCost > 0)) errors += "dust_cost_positive: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(CraftingRecipeRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(CraftingRecipeRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[CraftingRecipe] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(CraftingRecipeRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[CraftingRecipe] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(CraftingRecipeRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[CraftingRecipe] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(CraftingRecipeRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def canCraftAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement can_craft behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def executeCraft(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement execute_craft behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def disable(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement disable behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def enable(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement enable behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
