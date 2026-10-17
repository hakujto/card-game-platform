package cards_project.content.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class ArticleTagAssignmentControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"articletagassignment_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "ArticleTagAssignmentController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/article_tag_assignments")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "ArticleTagAssignmentController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/article_tag_assignments")
        .withJsonBody(Json.parse("""{"article_id": 1, "tag_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "ArticleTagAssignmentController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/article_tag_assignments/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

  "ArticleTagAssignmentController" should {
    "return 204 for delete" in {
      val createReq = FakeRequest(POST, "/api/article_tag_assignments")
        .withJsonBody(Json.parse("""{"article_id": 1, "tag_id": 1}"""))
      val createResult = route(app, createReq).get
      val id = (contentAsJson(createResult) \ "id").as[Long]
      val deleteReq = FakeRequest(DELETE, s"/api/article_tag_assignments/$id")
      val deleteResult = route(app, deleteReq).get
      status(deleteResult) mustBe NO_CONTENT
    }
  }

}
