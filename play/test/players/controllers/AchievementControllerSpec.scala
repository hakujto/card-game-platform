package cards_project.players.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class AchievementControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"achievement_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "AchievementController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/achievements")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "AchievementController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/achievements?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "AchievementController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/achievements")
        .withJsonBody(Json.parse("""{"name": "test", "description": "test", "points": 1, "rarity": "COMMON", "is_hidden": true}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "AchievementController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/achievements/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
