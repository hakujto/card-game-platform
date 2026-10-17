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
class DraftParticipantController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: DraftParticipant): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.seatNumber > 0)) errors += "seat_number_positive: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(DraftParticipantRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(DraftParticipantRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[DraftParticipant] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(DraftParticipantRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def pickCard(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement pick_card behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def draftedCardCountAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement drafted_card_count behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
