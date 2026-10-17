package cards_project.players.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.players.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class PlayerController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: Player): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.displayName.nonEmpty)) errors += "display_name_not_empty: validation failed"
    if (data.countryCode.exists(!_.matches("[A-Z]{2}"))) errors += "country_code must match pattern /[A-Z]{2}/"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): Action[AnyContent] = Action.async {
    db.run(PlayerRepository.list(skip, limit, q)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(PlayerRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def create(): Action[JsValue] = Action(parse.json).async { request =>
    request.body.validate[Player] match {
      case JsError(errors) => Future.successful(BadRequest(Json.obj("errors" -> JsError.toJson(errors))))
      case JsSuccess(data, _) =>
        val errs = validate(data)
        if (errs.nonEmpty) Future.successful(BadRequest(Json.obj("errors" -> errs)))
        else db.run(PlayerRepository.create(data)).map(created => Created(Json.toJson(created)))
    }
  }

  def patch(id: Long): Action[JsValue] = Action(parse.json).async { request =>
    val fields = request.body.as[Map[String, JsValue]]
    db.run(PlayerRepository.patch(id, fields)).map {
          case None       => NotFound(Json.obj("error" -> "not found"))
          case Some(item) => Ok(Json.toJson(item))
        }
  }

  def promote(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement promote behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def demote(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement demote behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def recordWin(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement record_win behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def recordLoss(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement record_loss behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def winRateAction(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement win_rate behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def verify(id: Long): Action[AnyContent] = Action.async {
    // TODO: check role from X-User-Role header
    // TODO: implement verify behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def updateRating(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement update_rating behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  // TODO: implement hook initialize_collection
  private def initializeCollection(item: Player): Unit = {}

  // TODO: implement hook update_rank
  private def updateRank(item: Player): Unit = {}

}
