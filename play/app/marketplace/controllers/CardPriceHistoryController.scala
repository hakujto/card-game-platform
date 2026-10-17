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
class CardPriceHistoryController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: CardPriceHistory): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!((data.minPrice <= data.avgPrice) && (data.avgPrice <= data.maxPrice))) errors += "price_bounds_consistent: validation failed"
    if (!(data.volume >= 0)) errors += "volume_not_negative: validation failed"
    if (!(data.minPrice >= BigDecimal("0"))) errors += "prices_not_negative: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(CardPriceHistoryRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(CardPriceHistoryRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def priceChangePercentAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement price_change_percent behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isPriceSpikeAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_price_spike behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

}
