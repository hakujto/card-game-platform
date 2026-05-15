using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Content;

public enum DraftSessionStatusType
{
    WaitingForPlayers,
    Drafting,
    Completed,
    Abandoned
}

public enum DraftSessionDraftTypeType
{
    Booster,
    Cube,
    Rochester
}

public class DraftSession
{
    public int Id { get; set; }

    public DraftSessionStatusType Status { get; set; }
    public DraftSessionDraftTypeType DraftType { get; set; }
    public int Seats { get; set; } = 8;
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? CompletedAt { get; set; } = null;

    public int? CardSetId { get; set; }
    [ForeignKey(nameof(CardSetId))]
    public CardSet? CardSet { get; set; }

    // Business operations

    public void Start()
    {
        throw new NotImplementedException("start not implemented");
    }

    public void Abandon()
    {
        throw new NotImplementedException("abandon not implemented");
    }

    public void Complete()
    {
        throw new NotImplementedException("complete not implemented");
    }

    public bool IsFull()
    {
        throw new NotImplementedException("is_full not implemented");
    }
}
