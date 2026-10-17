package cards_project.marketplace.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class ProductControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"product_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "ProductController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/products")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "ProductController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/products?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "ProductController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/products")
        .withJsonBody(Json.parse("""{"name": "test", "product_type": "SINGLECARD", "price": 1.00, "stock": 1, "active": true, "discount_percent": 1, "featured": true}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "ProductController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/products/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
