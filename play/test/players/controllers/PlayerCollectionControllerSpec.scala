package cards_project.players.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class PlayerCollectionControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"playercollection_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "PlayerCollectionController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/player_collections")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "PlayerCollectionController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/player_collections")
        .withJsonBody(Json.parse("""{"quantity": 1, "foil": true, "condition": "MINT", "acquired_at": "2024-01-01T00:00:00", "acquired_via": "PURCHASE", "player_id": 1, "card_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "PlayerCollectionController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/player_collections/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

  "PlayerCollectionController" should {
    "return 204 for delete" in {
      val createReq = FakeRequest(POST, "/api/player_collections")
        .withJsonBody(Json.parse("""{"quantity": 1, "foil": true, "condition": "MINT", "acquired_at": "2024-01-01T00:00:00", "acquired_via": "PURCHASE", "player_id": 1, "card_id": 1}"""))
      val createResult = route(app, createReq).get
      val id = (contentAsJson(createResult) \ "id").as[Long]
      val deleteReq = FakeRequest(DELETE, s"/api/player_collections/$id")
      val deleteResult = route(app, deleteReq).get
      status(deleteResult) mustBe NO_CONTENT
    }
  }

}
