package cards_project.content.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class DraftSessionControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"draftsession_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "DraftSessionController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/draft_sessions")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "DraftSessionController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/draft_sessions")
        .withJsonBody(Json.parse("""{"status": "WAITINGFORPLAYERS", "draft_type": "BOOSTER", "seats": 1, "time_per_pick_seconds": 1, "card_set_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "DraftSessionController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/draft_sessions/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
