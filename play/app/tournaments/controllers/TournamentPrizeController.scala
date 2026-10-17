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
class TournamentPrizeController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: TournamentPrize): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.placementTo >= data.placementFrom)) errors += "placement_range_valid: validation failed"
    if (!(data.placementFrom > 0)) errors += "placement_from_positive: validation failed"
    if (!(data.amount >= BigDecimal("0"))) errors += "amount_not_negative: validation failed"
    if (data.placementFrom < 1) errors += "placement_from must be >= 1"
    if (data.placementTo < 1) errors += "placement_to must be >= 1"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(TournamentPrizeRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TournamentPrizeRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TournamentPrize] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TournamentPrizeRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TournamentPrize] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TournamentPrizeRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TournamentPrize] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(TournamentPrizeRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def delete(id: Long): Action[AnyContent] = Action.async {
    db.run(TournamentPrizeRepository.delete(id)).map {
      case true  => NoContent
      case false => NotFound(Json.obj("error" -> "not found"))
    }
  }

  def appliesToPlacementAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement applies_to_placement behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def awardToPlayer(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement award_to_player behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
