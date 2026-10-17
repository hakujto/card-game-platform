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
class PlayerAchievementController @Inject()(cc: ControllerComponents, dbConfigProvider: DatabaseConfigProvider)(implicit ec: ExecutionContext)
  extends AbstractController(cc) {

  private val db = dbConfigProvider.get[H2Profile].db

  private def validate(data: PlayerAchievement): Seq[String] = {
    val errors = scala.collection.mutable.ArrayBuffer.empty[String]
    if (!(data.progress >= 0)) errors += "progress_not_negative: validation failed"
    errors.toSeq
  }

  def list(skip: Int = 0, limit: Int = 100): Action[AnyContent] = Action.async {
    db.run(PlayerAchievementRepository.list(skip, limit)).map(items => Ok(Json.toJson(items)))
  }

  def get(id: Long): Action[AnyContent] = Action.async {
    db.run(PlayerAchievementRepository.findById(id)).map {
      case None       => NotFound(Json.obj("error" -> "not found"))
      case Some(item) => Ok(Json.toJson(item))
    }
  }

  def incrementProgress(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement increment_progress behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  def complete(id: Long): Action[AnyContent] = Action.async {
    // TODO: implement complete behavior
    Future.successful(Ok(Json.obj("ok" -> true)))
  }

  private def complete(item: PlayerAchievement): Unit = {
    // @on(is_completed = true): triggered on update
  }

}
