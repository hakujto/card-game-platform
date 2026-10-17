package cards_project.marketplace.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class TradeListingControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"tradelisting_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "TradeListingController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/trade_listings")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "TradeListingController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/trade_listings?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "TradeListingController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/trade_listings")
        .withJsonBody(Json.parse("""{"public_id": "00000000-0000-0000-0000-000000000001", "listing_type": "FIXEDPRICE", "asking_price": 1.00, "foil": true, "condition": "MINT", "quantity": 1, "seller_id": 1, "card_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "TradeListingController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/trade_listings/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
