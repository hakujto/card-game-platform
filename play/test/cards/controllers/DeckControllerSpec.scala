package cards_project.cards.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class DeckControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"deck_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "DeckController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/decks")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "DeckController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/decks?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "DeckController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/decks")
        .withJsonBody(Json.parse("""{"name": "test", "format": "STANDARD", "is_public": true, "is_tournament_legal": true, "player_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "DeckController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/decks/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

  "DeckController" should {
    "return 204 for delete" in {
      val createReq = FakeRequest(POST, "/api/decks")
        .withJsonBody(Json.parse("""{"name": "test", "format": "STANDARD", "is_public": true, "is_tournament_legal": true, "player_id": 1}"""))
      val createResult = route(app, createReq).get
      val id = (contentAsJson(createResult) \ "id").as[Long]
      val deleteReq = FakeRequest(DELETE, s"/api/decks/$id")
      val deleteResult = route(app, deleteReq).get
      status(deleteResult) mustBe NO_CONTENT
    }
  }

}
