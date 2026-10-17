package cards_project.marketplace.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class TradeBidControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"tradebid_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "TradeBidController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/trade_bids")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "TradeBidController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/trade_bids")
        .withJsonBody(Json.parse("""{"amount": 1.00, "placed_at": "2024-01-01T00:00:00", "is_winning": true, "listing_id": 1, "bidder_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "TradeBidController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/trade_bids/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
