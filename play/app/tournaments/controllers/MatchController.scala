package cards_project.tournaments.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.tournaments.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class MatchController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Match): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!((data.player1Wins >= 0) && (data.player2Wins >= 0))) errors += "wins_not_negative: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(MatchRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(MatchRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Match] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(MatchRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def recordResult(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement record_result behavior
    // TODO: determineWinner() // @after
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def finalizeResult(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement finalize_result behavior
    // TODO: determineWinner() // @after
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def determineWinnerAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement determine_winner behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def concede(id: Long): Action[AnyContent] = Action.async {
    // @guard: TODO: check guard condition
    // TODO: implement concede behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def draw(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement draw behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def transitionPendingToActive(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Judge, HeadJudge, Admin
    db.run(MatchRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Pending") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Active")))
        else db.run(MatchRepository.updateStatus(id, "Active")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionActiveToCompleted(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Judge, HeadJudge, Admin
    db.run(MatchRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Active") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Completed")))
        else db.run(MatchRepository.updateStatus(id, "Completed")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionActiveToDraw(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Judge, HeadJudge, Admin
    db.run(MatchRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Active") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Draw")))
        else db.run(MatchRepository.updateStatus(id, "Draw")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionPendingToBYE(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Judge, HeadJudge, Admin
    db.run(MatchRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Pending") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to BYE")))
        else db.run(MatchRepository.updateStatus(id, "BYE")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionCompletedToActive(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Completed -> Active is not allowed")))
  }

  def transitionDrawToActive(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Draw -> Active is not allowed")))
  }

  def transitionBYEToActive(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition BYE -> Active is not allowed")))
  }

}
