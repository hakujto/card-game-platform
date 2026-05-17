defmodule CardsProject.Content do
  @moduledoc """
  The Content BC context.
  """

  import Ecto.Query, warn: false
  alias CardsProject.Repo

  alias CardsProject.Content.DraftSession
  alias CardsProject.Content.DraftParticipant
  alias CardsProject.Content.DraftPick
  alias CardsProject.Content.Article
  alias CardsProject.Content.ArticleTag
  alias CardsProject.Content.ArticleTagAssignment
  alias CardsProject.Content.ArticleComment
  alias CardsProject.Content.Stream

  # ── DraftSession ─────────────────────────────────────────────────────

  def list_draft_sessions, do: Repo.all(DraftSession)

  def get_draft_session!(id), do: Repo.get!(DraftSession, id)

  def create_draft_session(attrs \\ %{}) do
    %DraftSession{}
    |> DraftSession.changeset(attrs)
    |> Repo.insert()
  end

  def update_draft_session(%DraftSession{} = draft_session, attrs) do
    draft_session
    |> DraftSession.changeset(attrs)
    |> Repo.update()
  end

  def delete_draft_session(%DraftSession{} = draft_session), do: Repo.delete(draft_session)

  def change_draft_session(%DraftSession{} = draft_session, attrs \\ %{}) do
    DraftSession.changeset(draft_session, attrs)
  end

  def draft_session_start_behavior(id) do
    draft_session = Repo.get!(DraftSession, id)
    DraftSession.start(draft_session)
    Repo.update!(DraftSession.changeset(draft_session, %{}))
  end

  def draft_session_abandon_behavior(id) do
    draft_session = Repo.get!(DraftSession, id)
    DraftSession.abandon(draft_session)
    Repo.update!(DraftSession.changeset(draft_session, %{}))
  end

  def draft_session_complete_behavior(id) do
    draft_session = Repo.get!(DraftSession, id)
    DraftSession.complete(draft_session)
    Repo.update!(DraftSession.changeset(draft_session, %{}))
  end

  # ── DraftParticipant ─────────────────────────────────────────────────────

  def list_draft_participants, do: Repo.all(DraftParticipant)

  def get_draft_participant!(id), do: Repo.get!(DraftParticipant, id)

  def create_draft_participant(attrs \\ %{}) do
    %DraftParticipant{}
    |> DraftParticipant.changeset(attrs)
    |> Repo.insert()
  end

  def update_draft_participant(%DraftParticipant{} = draft_participant, attrs) do
    draft_participant
    |> DraftParticipant.changeset(attrs)
    |> Repo.update()
  end

  def delete_draft_participant(%DraftParticipant{} = draft_participant), do: Repo.delete(draft_participant)

  def change_draft_participant(%DraftParticipant{} = draft_participant, attrs \\ %{}) do
    DraftParticipant.changeset(draft_participant, attrs)
  end

  def draft_participant_pick_card_behavior(id, card_id, pack_number) do
    draft_participant = Repo.get!(DraftParticipant, id)
    DraftParticipant.pick_card(draft_participant, card_id, pack_number)
    Repo.update!(DraftParticipant.changeset(draft_participant, %{}))
  end

  # ── DraftPick ─────────────────────────────────────────────────────

  def list_draft_picks, do: Repo.all(DraftPick)

  def get_draft_pick!(id), do: Repo.get!(DraftPick, id)

  def create_draft_pick(attrs \\ %{}) do
    %DraftPick{}
    |> DraftPick.changeset(attrs)
    |> Repo.insert()
  end

  def update_draft_pick(%DraftPick{} = draft_pick, attrs) do
    draft_pick
    |> DraftPick.changeset(attrs)
    |> Repo.update()
  end

  def delete_draft_pick(%DraftPick{} = draft_pick), do: Repo.delete(draft_pick)

  def change_draft_pick(%DraftPick{} = draft_pick, attrs \\ %{}) do
    DraftPick.changeset(draft_pick, attrs)
  end

  # ── Article ─────────────────────────────────────────────────────

  def list_articles, do: Repo.all(Article)

  def get_article!(id), do: Repo.get!(Article, id)

  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  def delete_article(%Article{} = article), do: Repo.delete(article)

  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  def article_publish_behavior(id) do
    article = Repo.get!(Article, id)
    Article.publish(article)
    Repo.update!(Article.changeset(article, %{}))
  end

  def article_archive_behavior(id) do
    article = Repo.get!(Article, id)
    Article.archive(article)
    Repo.update!(Article.changeset(article, %{}))
  end

  def article_increment_view_behavior(id) do
    article = Repo.get!(Article, id)
    Article.increment_view(article)
    Repo.update!(Article.changeset(article, %{}))
  end

  # ── ArticleTag ─────────────────────────────────────────────────────

  def list_article_tags, do: Repo.all(ArticleTag)

  def get_article_tag!(id), do: Repo.get!(ArticleTag, id)

  def create_article_tag(attrs \\ %{}) do
    %ArticleTag{}
    |> ArticleTag.changeset(attrs)
    |> Repo.insert()
  end

  def update_article_tag(%ArticleTag{} = article_tag, attrs) do
    article_tag
    |> ArticleTag.changeset(attrs)
    |> Repo.update()
  end

  def delete_article_tag(%ArticleTag{} = article_tag), do: Repo.delete(article_tag)

  def change_article_tag(%ArticleTag{} = article_tag, attrs \\ %{}) do
    ArticleTag.changeset(article_tag, attrs)
  end

  # ── ArticleTagAssignment ─────────────────────────────────────────────────────

  def list_article_tag_assignments, do: Repo.all(ArticleTagAssignment)

  def get_article_tag_assignment!(id), do: Repo.get!(ArticleTagAssignment, id)

  def create_article_tag_assignment(attrs \\ %{}) do
    %ArticleTagAssignment{}
    |> ArticleTagAssignment.changeset(attrs)
    |> Repo.insert()
  end

  def update_article_tag_assignment(%ArticleTagAssignment{} = article_tag_assignment, attrs) do
    article_tag_assignment
    |> ArticleTagAssignment.changeset(attrs)
    |> Repo.update()
  end

  def delete_article_tag_assignment(%ArticleTagAssignment{} = article_tag_assignment), do: Repo.delete(article_tag_assignment)

  def change_article_tag_assignment(%ArticleTagAssignment{} = article_tag_assignment, attrs \\ %{}) do
    ArticleTagAssignment.changeset(article_tag_assignment, attrs)
  end

  # ── ArticleComment ─────────────────────────────────────────────────────

  def list_article_comments, do: Repo.all(ArticleComment)

  def get_article_comment!(id), do: Repo.get!(ArticleComment, id)

  def create_article_comment(attrs \\ %{}) do
    %ArticleComment{}
    |> ArticleComment.changeset(attrs)
    |> Repo.insert()
  end

  def update_article_comment(%ArticleComment{} = article_comment, attrs) do
    article_comment
    |> ArticleComment.changeset(attrs)
    |> Repo.update()
  end

  def delete_article_comment(%ArticleComment{} = article_comment), do: Repo.delete(article_comment)

  def change_article_comment(%ArticleComment{} = article_comment, attrs \\ %{}) do
    ArticleComment.changeset(article_comment, attrs)
  end

  def article_comment_hide_behavior(id) do
    article_comment = Repo.get!(ArticleComment, id)
    ArticleComment.hide(article_comment)
    Repo.update!(ArticleComment.changeset(article_comment, %{}))
  end

  def article_comment_unhide_behavior(id) do
    article_comment = Repo.get!(ArticleComment, id)
    ArticleComment.unhide(article_comment)
    Repo.update!(ArticleComment.changeset(article_comment, %{}))
  end

  # ── Stream ─────────────────────────────────────────────────────

  def list_streams, do: Repo.all(Stream)

  def get_stream!(id), do: Repo.get!(Stream, id)

  def create_stream(attrs \\ %{}) do
    %Stream{}
    |> Stream.changeset(attrs)
    |> Repo.insert()
  end

  def update_stream(%Stream{} = stream, attrs) do
    stream
    |> Stream.changeset(attrs)
    |> Repo.update()
  end

  def delete_stream(%Stream{} = stream), do: Repo.delete(stream)

  def change_stream(%Stream{} = stream, attrs \\ %{}) do
    Stream.changeset(stream, attrs)
  end

  def stream_go_live_behavior(id) do
    stream = Repo.get!(Stream, id)
    Stream.go_live(stream)
    Repo.update!(Stream.changeset(stream, %{}))
  end

  def stream_end_action_behavior(id) do
    stream = Repo.get!(Stream, id)
    Stream.end_action(stream)
    Repo.update!(Stream.changeset(stream, %{}))
  end

  def stream_update_viewer_peak_behavior(id, count) do
    stream = Repo.get!(Stream, id)
    Stream.update_viewer_peak(stream, count)
    Repo.update!(Stream.changeset(stream, %{}))
  end

end
