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
class TradeTransactionController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: TradeTransaction): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.platformFee <= data.finalPrice)) errors += "fee_not_exceed_price: validation failed"
    if (!(data.platformFee >= BigDecimal("0"))) errors += "fee_not_negative: validation failed"
    if (!(data.finalPrice > BigDecimal("0"))) errors += "final_price_positive: validation failed"
    if ((data.status == "COMPLETED") && data.completedAt.isEmpty) errors += "completed_at is required when condition is met"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(TradeTransactionRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TradeTransactionRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def complete(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement complete behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def refund(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement refund behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def openDispute(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement open_dispute behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def sellerNetAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement seller_net behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
