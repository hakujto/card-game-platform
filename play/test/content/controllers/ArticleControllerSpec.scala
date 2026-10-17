package cards_project.content.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class ArticleControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"article_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "ArticleController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/articles")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "ArticleController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/articles?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "ArticleController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/articles")
        .withJsonBody(Json.parse("""{"title": "test", "slug": "test", "body": "test", "article_type": "GUIDE", "language": "EN", "total_views_alltime": 1, "is_featured": true, "author_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "ArticleController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/articles/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
