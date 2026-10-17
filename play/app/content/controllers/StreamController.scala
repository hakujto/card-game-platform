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
class StreamController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Stream): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.viewerCountPeak >= 0)) errors += "viewer_count_not_negative: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(StreamRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(StreamRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Stream] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(StreamRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Stream] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(StreamRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Stream] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(StreamRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def goLive(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement go_live behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def end(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement end behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def updateViewerPeak(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement update_viewer_peak behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def durationMinutesAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement duration_minutes behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def transitionScheduledToLive(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Streamer, Admin
    db.run(StreamRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Scheduled") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Live")))
        else db.run(StreamRepository.updateStatus(id, "Live")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionLiveToEnded(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Streamer, Admin
    db.run(StreamRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Live") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Ended")))
        else db.run(StreamRepository.updateStatus(id, "Ended")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionEndedToLive(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Ended -> Live is not allowed")))
  }

}
