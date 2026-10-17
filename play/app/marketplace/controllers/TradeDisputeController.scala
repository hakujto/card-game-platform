package cards_project.marketplace.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.marketplace.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class TradeDisputeController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: TradeDispute): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(TradeDisputeRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TradeDisputeRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TradeDispute] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TradeDisputeRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def escalate(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement escalate behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def resolve(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement resolve behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def closeResolved(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement close_resolved behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def review(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement review behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def transitionOpenToUnderReview(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Moderator
    db.run(TradeDisputeRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Open") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to UnderReview")))
        else db.run(TradeDisputeRepository.updateStatus(id, "UnderReview")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionUnderReviewToResolved(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Moderator
    db.run(TradeDisputeRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "UnderReview") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Resolved")))
        else db.run(TradeDisputeRepository.updateStatus(id, "Resolved")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionUnderReviewToEscalated(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin
    db.run(TradeDisputeRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "UnderReview") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Escalated")))
        else db.run(TradeDisputeRepository.updateStatus(id, "Escalated")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionEscalatedToResolved(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin
    db.run(TradeDisputeRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Escalated") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Resolved")))
        else db.run(TradeDisputeRepository.updateStatus(id, "Resolved")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionResolvedToOpen(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Resolved -> Open is not allowed")))
  }

}
