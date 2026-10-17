package cards_project.tournaments.controllers

import javax.inject._
import play.api.libs.json._
import play.api.mvc._
import play.api.db.slick.DatabaseConfigProvider
import slick.jdbc.H2Profile
import slick.jdbc.H2Profile.api._
import cards_project.tournaments.models._
import scala.concurrent.{ExecutionContext, Future}

@Singleton
class AwardedPrizeController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: AwardedPrize): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if ((data.claimed == true) && data.claimedAt.isEmpty) errors += "claimed_at is required when condition is met"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(AwardedPrizeRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(AwardedPrizeRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def claim(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement claim behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  private def claim(item: AwardedPrize): Unit = {
    // @on(claimed = true): triggered on update
  }

}
