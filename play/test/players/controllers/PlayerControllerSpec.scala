package cards_project.players.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class PlayerControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"player_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "PlayerController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/players")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "PlayerController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/players?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "PlayerController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/players")
        .withJsonBody(Json.parse("""{"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test_player_001", "rank": "BRONZE", "is_verified": true, "user_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "PlayerController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/players/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
