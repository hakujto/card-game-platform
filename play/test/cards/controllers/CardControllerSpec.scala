package cards_project.cards.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class CardControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"card_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "CardController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/cards")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CardController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/cards?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CardController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/cards")
        .withJsonBody(Json.parse("""{"public_id": "00000000-0000-0000-0000-000000000001", "name": "Test Lightning Bolt", "card_type": "SPELL", "rarity": "COMMON", "mana_cost": 1, "mana_colors": "WHITE", "attack": 1, "defense": 1, "loyalty": 1, "description": "test", "legal_formats": "STANDARD", "power_level": 3, "total_copies_in_circulation": 1, "set_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "CardController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/cards/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
