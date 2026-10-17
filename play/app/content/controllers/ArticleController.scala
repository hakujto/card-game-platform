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
class ArticleController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Article): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(ArticleRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(ArticleRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Article] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(ArticleRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Article] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(ArticleRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    val fields = request.body.as[Map[String, JsValue]]
    db.run(ArticleRepository.patch(id, fields)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
  }

  def publish(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement publish behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def archive(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement archive behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def replace(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement replace behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def incrementView(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement increment_view behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def like(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement like behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def unlike(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement unlike behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def readingTimeMinutesAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement reading_time_minutes behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def transitionDraftToPublished(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Editor, Admin
    db.run(ArticleRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Draft") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Published")))
        else db.run(ArticleRepository.updateStatus(id, "Published")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionPublishedToArchived(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Editor, Admin
    db.run(ArticleRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Published") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Archived")))
        else db.run(ArticleRepository.updateStatus(id, "Archived")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionArchivedToDraft(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin
    db.run(ArticleRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Archived") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Draft")))
        else db.run(ArticleRepository.updateStatus(id, "Draft")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionPublishedToDraft(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Published -> Draft is not allowed")))
  }

  // TODO: implement hook update_search_index
  private def updateSearchIndex(item: Article): Unit = {}

}
