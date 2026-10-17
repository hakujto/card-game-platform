package cards_project.cards.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class CardAbilityControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"cardability_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "CardAbilityController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/card_abilities")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CardAbilityController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/card_abilities?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CardAbilityController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/card_abilities")
        .withJsonBody(Json.parse("""{"ability_type": "KEYWORD", "ability_text": "test", "card_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "CardAbilityController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/card_abilities/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

  "CardAbilityController" should {
    "return 204 for delete" in {
      val createReq = FakeRequest(POST, "/api/card_abilities")
        .withJsonBody(Json.parse("""{"ability_type": "KEYWORD", "ability_text": "test", "card_id": 1}"""))
      val createResult = route(app, createReq).get
      val id = (contentAsJson(createResult) \ "id").as[Long]
      val deleteReq = FakeRequest(DELETE, s"/api/card_abilities/$id")
      val deleteResult = route(app, deleteReq).get
      status(deleteResult) mustBe NO_CONTENT
    }
  }

}
