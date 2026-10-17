package cards_project.marketplace.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class OrderItemControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"orderitem_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "OrderItemController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/order_items")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "OrderItemController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/order_items")
        .withJsonBody(Json.parse("""{"quantity": 1, "price_at_purchase": 1.00, "foil": true, "order_id": 1, "product_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "OrderItemController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/order_items/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

  "OrderItemController" should {
    "return 204 for delete" in {
      val createReq = FakeRequest(POST, "/api/order_items")
        .withJsonBody(Json.parse("""{"quantity": 1, "price_at_purchase": 1.00, "foil": true, "order_id": 1, "product_id": 1}"""))
      val createResult = route(app, createReq).get
      val id = (contentAsJson(createResult) \ "id").as[Long]
      val deleteReq = FakeRequest(DELETE, s"/api/order_items/$id")
      val deleteResult = route(app, deleteReq).get
      status(deleteResult) mustBe NO_CONTENT
    }
  }

}
