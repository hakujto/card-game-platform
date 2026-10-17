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
class CardSetController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: CardSet): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.totalCards > 0)) errors += "total_cards_positive: validation failed"
    if (!data.code.matches("[A-Z]{2,6}")) errors += "code must match pattern /[A-Z]{2,6}/"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(CardSetRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(CardSetRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[CardSet] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(CardSetRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[CardSet] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(CardSetRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[CardSet] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(CardSetRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def isLegalInStandardAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_legal_in_standard behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isLegalInFormatAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_legal_in_format behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def cardCountByRarityAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement card_count_by_rarity behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def rotateOut(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement rotate_out behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
