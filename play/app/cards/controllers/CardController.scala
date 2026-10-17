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
class CardController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Card): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (data.manaCost < 0) errors += "mana_cost must be >= 0"
    if (data.manaCost > 20) errors += "mana_cost must be <= 20"
    if (data.powerLevel < 1) errors += "power_level must be >= 1"
    if (data.powerLevel > 10) errors += "power_level must be <= 10"
    if ((data.cardType == "CREATURE") && data.attack.isEmpty) errors += "attack is required when condition is met"
    if ((data.cardType == "CREATURE") && data.defense.isEmpty) errors += "defense is required when condition is met"
    if ((data.cardType == "PLANESWALKER") && data.loyalty.isEmpty) errors += "loyalty is required when condition is met"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(CardRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(CardRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Card] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(CardRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Card] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(CardRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    val fields = request.body.as[Map[String, JsValue]]
    db.run(CardRepository.patch(id, fields)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
  }

  def ban(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement ban behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def unban(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement unban behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def restrict(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement restrict behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def unrestrict(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement unrestrict behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def replace(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement replace behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def calculateValueAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement calculate_value behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def applyRarityBonus(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement apply_rarity_bonus behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isLegalInFormatAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_legal_in_format behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  // TODO: implement hook validate_legality
  private def validateLegality(item: Card): Unit = {}

  // TODO: implement hook validate_not_in_use
  private def validateNotInUse(item: Card): Unit = {}

}
