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
class TradeListingController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: TradeListing): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if ((data.listingType == "FIXEDPRICE") && data.askingPrice.isEmpty) errors += "asking_price is required when condition is met"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(TradeListingRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(TradeListingRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TradeListing] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(TradeListingRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[TradeListing] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        db.run(TradeListingRepository.update(id, data)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def close(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement close behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def extend(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement extend behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def cancel(id: Long): Action[AnyContent] = Action.async {
    // @guard: TODO: check guard condition
    // TODO: implement cancel behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def isExpiredAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement is_expired behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def finalizeAuction(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement finalize_auction behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  private def finalizeAuction(item: TradeListing): Unit = {
    // @on(status = Sold): triggered on update
  }

  def transitionPendingToActive(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Seller
    db.run(TradeListingRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Pending") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Active")))
        else db.run(TradeListingRepository.updateStatus(id, "Active")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionActiveToSold(id: Long): Action[AnyContent] = Action.async {
    db.run(TradeListingRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Active") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Sold")))
        else db.run(TradeListingRepository.updateStatus(id, "Sold")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionActiveToExpired(id: Long): Action[AnyContent] = Action.async {
    db.run(TradeListingRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Active") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Expired")))
        else db.run(TradeListingRepository.updateStatus(id, "Expired")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionActiveToCancelled(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Seller, Admin
    db.run(TradeListingRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Active") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Cancelled")))
        else db.run(TradeListingRepository.updateStatus(id, "Cancelled")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionSoldToActive(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Sold -> Active is not allowed")))
  }

  def transitionExpiredToActive(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Expired -> Active is not allowed")))
  }

}
