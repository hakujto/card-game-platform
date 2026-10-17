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
class TournamentRegistrationController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: TournamentRegistration): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.pointsEarned >= 0)) errors += "points_earned_not_negative: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(TournamentRegistrationRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TournamentRegistrationRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) =>
        // TODO: check ownership: item.playerId vs X-User-Id header
        Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TournamentRegistration] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TournamentRegistrationRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def withdraw(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement withdraw behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def disqualify(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement disqualify behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def promoteFromWaitlist(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement promote_from_waitlist behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
