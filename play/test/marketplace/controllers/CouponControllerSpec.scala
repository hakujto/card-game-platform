package cards_project.marketplace.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class CouponControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"coupon_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "CouponController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/coupons")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CouponController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/coupons?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CouponController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/coupons")
        .withJsonBody(Json.parse("""{"code": "test", "discount_type": "PERCENT", "discount_value": 1.00, "min_order_value": 1.00, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-12-31T00:00:00", "is_active": true}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "CouponController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/coupons/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
