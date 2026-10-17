package cards_project.marketplace.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class OrderControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"order_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "OrderController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/orders")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "OrderController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/orders")
        .withJsonBody(Json.parse("""{"total": 29.99, "discount_applied": 1.00, "currency": "USD", "tracking_number": "test", "player_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "OrderController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/orders/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
