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
class DraftSessionController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: DraftSession): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.timePerPickSeconds > 0)) errors += "time_per_pick_positive: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(DraftSessionRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(DraftSessionRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[DraftSession] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(DraftSessionRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def start(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement start behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def abandon(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement abandon behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def complete(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement complete behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isFullAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_full behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def transitionWaitingForPlayersToDrafting(id: Long): Action[AnyContent] = Action.async {
    db.run(DraftSessionRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "WaitingForPlayers") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Drafting")))
        else db.run(DraftSessionRepository.updateStatus(id, "Drafting")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionDraftingToCompleted(id: Long): Action[AnyContent] = Action.async {
    db.run(DraftSessionRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Drafting") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Completed")))
        else db.run(DraftSessionRepository.updateStatus(id, "Completed")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionDraftingToAbandoned(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Organizer
    db.run(DraftSessionRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Drafting") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Abandoned")))
        else db.run(DraftSessionRepository.updateStatus(id, "Abandoned")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionWaitingForPlayersToAbandoned(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Organizer
    db.run(DraftSessionRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "WaitingForPlayers") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Abandoned")))
        else db.run(DraftSessionRepository.updateStatus(id, "Abandoned")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionCompletedToDrafting(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Completed -> Drafting is not allowed")))
  }

  def transitionAbandonedToDrafting(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Abandoned -> Drafting is not allowed")))
  }

}
