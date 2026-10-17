package cards_project.cards.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class CardSetControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"cardset_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "CardSetController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/card_sets")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CardSetController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/card_sets?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CardSetController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/card_sets")
        .withJsonBody(Json.parse("""{"name": "test", "code": "AA", "release_date": "2024-01-01", "set_type": "CORE", "total_cards": 1, "is_rotated": true}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "CardSetController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/card_sets/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
