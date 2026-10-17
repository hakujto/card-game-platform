package cards_project.cards.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class CardRulingControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"cardruling_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "CardRulingController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/card_rulings")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CardRulingController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/card_rulings")
        .withJsonBody(Json.parse("""{"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "CardRulingController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/card_rulings/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

  "CardRulingController" should {
    "return 204 for delete" in {
      val createReq = FakeRequest(POST, "/api/card_rulings")
        .withJsonBody(Json.parse("""{"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": 1}"""))
      val createResult = route(app, createReq).get
      val id = (contentAsJson(createResult) \ "id").as[Long]
      val deleteReq = FakeRequest(DELETE, s"/api/card_rulings/$id")
      val deleteResult = route(app, deleteReq).get
      status(deleteResult) mustBe NO_CONTENT
    }
  }

}
