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
class ProductController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Product): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.price > BigDecimal("0"))) errors += "price_positive: validation failed"
    if (!(data.stock >= 0)) errors += "stock_not_negative: validation failed"
    if (data.discountPercent < 0) errors += "discount_percent must be >= 0"
    if (data.discountPercent > 100) errors += "discount_percent must be <= 100"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(ProductRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(ProductRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Product] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(ProductRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def update(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Product] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(ProductRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    val fields = request.body.as[Map[String, JsValue]]
    db.run(ProductRepository.patch(id, fields)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
  }

  def activate(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement activate behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def deactivate(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement deactivate behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def applyDiscount(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement apply_discount behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def restock(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement restock behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def effectivePriceAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement effective_price behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isInStockAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_in_stock behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
