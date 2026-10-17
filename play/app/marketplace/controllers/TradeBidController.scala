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
class TradeBidController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: TradeBid): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.amount > BigDecimal("0"))) errors += "amount_positive: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(TradeBidRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TradeBidRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TradeBid] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TradeBidRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def outbidByAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement outbid_by behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def retract(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement retract behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
