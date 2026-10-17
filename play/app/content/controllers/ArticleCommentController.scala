package cards_project.content.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.content.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class ArticleCommentController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(ArticleCommentRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(ArticleCommentRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[ArticleComment] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(ArticleCommentRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def delete(id: Long): Action[AnyContent] = Action.async {
    db.run(ArticleCommentRepository.delete(id)).map {
      case true  => NoContent
      case false => NotFound(Json.obj("error" -> "not found"))
    }
  }

  def hide(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement hide behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def unhide(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement unhide behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isReplyAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_reply behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
