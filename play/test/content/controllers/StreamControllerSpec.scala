package cards_project.content.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class StreamControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"stream_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "StreamController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/streams")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "StreamController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/streams?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "StreamController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/streams")
        .withJsonBody(Json.parse("""{"title": "test", "stream_url": "https://example.com", "status": "SCHEDULED", "platform": "TWITCH", "language": "EN", "is_official": true, "viewer_count_peak": 1, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "StreamController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/streams/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
