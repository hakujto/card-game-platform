package cards_project.cards.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.cards.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class DeckController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Deck): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(DeckRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(DeckRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Deck] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(DeckRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Deck] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(DeckRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    val fields = request.body.as[Map[String, JsValue]]
    db.run(DeckRepository.patch(id, fields)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
  }

  def delete(id: Long): Action[AnyContent] = Action.async {
    db.run(DeckRepository.delete(id)).map {
      case true  => NoContent
      case false => NotFound(Json.obj("error" -> "not found"))
    }
  }

  def validateSizeAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement validate_size behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def addCard(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement add_card behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def removeCard(id: Long, card_id: Long): Action[AnyContent] = Action.async {
    // TODO: implement remove_card behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def winRateAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement win_rate behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def cloneAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement clone behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def publish(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement publish behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def unpublish(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement unpublish behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def certifyTournamentLegal(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement certify_tournament_legal behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  // TODO: implement hook recalculate_tournament_legal
  private def recalculateTournamentLegal(item: Deck): Unit = {}

}
