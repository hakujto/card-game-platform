package cards_project.players.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class PlayerAchievementControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"playerachievement_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "PlayerAchievementController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/player_achievements")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "PlayerAchievementController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/player_achievements/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
