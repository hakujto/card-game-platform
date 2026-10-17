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
class TournamentController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Tournament): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.entryFee >= BigDecimal("0"))) errors += "entry_fee_not_negative: validation failed"
    if (!(data.prizePool >= BigDecimal("0"))) errors += "prize_pool_not_negative: validation failed"
    if (data.maxPlayers < 2) errors += "max_players must be >= 2"
    if (data.maxPlayers > 512) errors += "max_players must be <= 512"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(TournamentRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TournamentRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Tournament] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TournamentRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Tournament] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TournamentRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    val fields = request.body.as[Map[String, JsValue]]
    db.run(TournamentRepository.patch(id, fields)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
  }

  def start(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement start behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def cancel(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement cancel behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def complete(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement complete behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def generateRound(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement generate_round behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def calculatePrizeDistributionAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement calculate_prize_distribution behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def registerPlayer(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement register_player behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isFullAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_full behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def transitionDraftToRegistration(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Organizer
    db.run(TournamentRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Draft") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Registration")))
        else db.run(TournamentRepository.updateStatus(id, "Registration")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionRegistrationToOngoing(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Organizer
    db.run(TournamentRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Registration") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Ongoing")))
        else db.run(TournamentRepository.updateStatus(id, "Ongoing")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionRegistrationToCancelled(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Organizer
    db.run(TournamentRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Registration") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Cancelled")))
        else db.run(TournamentRepository.updateStatus(id, "Cancelled")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionOngoingToCompleted(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Organizer
    db.run(TournamentRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Ongoing") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Completed")))
        else db.run(TournamentRepository.updateStatus(id, "Completed")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionOngoingToCancelled(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin
    db.run(TournamentRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Ongoing") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Cancelled")))
        else db.run(TournamentRepository.updateStatus(id, "Cancelled")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionCompletedToDraft(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Completed -> Draft is not allowed")))
  }

  def transitionCancelledToDraft(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Cancelled -> Draft is not allowed")))
  }

  // TODO: implement hook sync_season_stats
  private def syncSeasonStats(item: Tournament): Unit = {}

  // TODO: implement hook prevent_delete_if_ongoing
  private def preventDeleteIfOngoing(item: Tournament): Unit = {}

}
