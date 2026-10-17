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
class OrderController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Order): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.total >= BigDecimal("0"))) errors += "total_not_negative: validation failed"
    if (!(data.discountApplied <= data.total)) errors += "discount_not_exceed_total: validation failed"
    if (!data.currency.matches("[A-Z]{3}")) errors += "currency must match pattern /[A-Z]{3}/"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(OrderRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(OrderRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) =>
        // TODO: check ownership: item.playerId vs X-User-Id header
        Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Order] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(OrderRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def cancel(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement cancel behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def pay(id: Long): Action[AnyContent] = Action.async {
    // @guard: TODO: check guard condition
    // TODO: implement pay behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def processPayment(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement process_payment behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def calculateTotalAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement calculate_total behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def applyDiscount(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement apply_discount behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def refund(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement refund behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  private def notifyShipped(item: Order): Unit = {
    // @on(status = Shipped): triggered on update
  }

  def transitionPendingToPaid(id: Long): Action[AnyContent] = Action.async {
    db.run(OrderRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Pending") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Paid")))
        else db.run(OrderRepository.updateStatus(id, "Paid")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionPaidToProcessing(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Staff
    db.run(OrderRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Paid") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Processing")))
        else db.run(OrderRepository.updateStatus(id, "Processing")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionProcessingToShipped(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Staff
    db.run(OrderRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Processing") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Shipped")))
        else db.run(OrderRepository.updateStatus(id, "Shipped")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionShippedToCompleted(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Staff
    db.run(OrderRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Shipped") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Completed")))
        else db.run(OrderRepository.updateStatus(id, "Completed")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionPendingToCancelled(id: Long): Action[AnyContent] = Action.async {
    db.run(OrderRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Pending") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Cancelled")))
        else db.run(OrderRepository.updateStatus(id, "Cancelled")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionPaidToCancelled(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin, Staff
    db.run(OrderRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Paid") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Cancelled")))
        else db.run(OrderRepository.updateStatus(id, "Cancelled")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionCompletedToRefunded(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role — require one of: Admin
    db.run(OrderRepository.findById(id)).flatMap {
      case None => Future.successful(NotFound(Json.obj("error" -> "not found")))
      case Some(item) =>
        val fromStatus = item.status.toString
        if (fromStatus != "Completed") Future.successful(Conflict(Json.obj("error" -> s"Cannot transition from $fromStatus to Refunded")))
        else db.run(OrderRepository.updateStatus(id, "Refunded")).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
    }
  }

  def transitionRefundedToCompleted(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Refunded -> Completed is not allowed")))
  }

  def transitionCompletedToCancelled(id: Long): Action[AnyContent] = Action.async {
    Future.successful(Conflict(Json.obj("error" -> "Transition Completed -> Cancelled is not allowed")))
  }

  // TODO: implement hook assign_currency_default
  private def assignCurrencyDefault(item: Order): Unit = {}

  // TODO: implement hook notify_status_change
  private def notifyStatusChange(item: Order): Unit = {}

}
