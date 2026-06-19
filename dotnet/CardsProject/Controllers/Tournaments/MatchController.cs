using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Tournaments;

namespace CardsProject.Controllers.Tournaments;

[ApiController]
[Route("api/matches")]
public class MatchController : ControllerBase
{
    private readonly MatchService _svc;

    public MatchController(MatchService svc) => _svc = svc;

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] MatchDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        try
        {
            var entity = await _svc.CreateAsync(dto);
            return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) { return BadRequest(new { error = ex.InnerException?.Message ?? ex.Message }); }
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpPost("{id:int}/record")]
    public async System.Threading.Tasks.Task<IActionResult> RecordResult(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var p1Wins = (int)body["p1_wins"];
            var p2Wins = (int)body["p2_wins"];
            await _svc.RecordResultAsync(id, p1Wins, p2Wins);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/finalize")]
    public async System.Threading.Tasks.Task<IActionResult> FinalizeResult(int id)
    {
        try
        {
            await _svc.FinalizeResultAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/winner")]
    public async System.Threading.Tasks.Task<IActionResult> DetermineWinner(int id)
    {
        try
        {
            var result = await _svc.DetermineWinnerAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/concede")]
    public async System.Threading.Tasks.Task<IActionResult> Concede(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var playerId = (int)body["player_id"];
            await _svc.ConcedeAsync(id, playerId);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/draw")]
    public async System.Threading.Tasks.Task<IActionResult> Draw(int id)
    {
        try
        {
            await _svc.DrawAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Judge,HeadJudge,Admin")]
    [HttpPatch("{id:int}/transitions/pending-to-active")]
    public async Task<IActionResult> TransitionPendingToActive(int id)
    {
        try { return Ok(await _svc.TransitionPendingToActiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Judge,HeadJudge,Admin")]
    [HttpPatch("{id:int}/transitions/active-to-completed")]
    public async Task<IActionResult> TransitionActiveToCompleted(int id)
    {
        try { return Ok(await _svc.TransitionActiveToCompletedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Judge,HeadJudge,Admin")]
    [HttpPatch("{id:int}/transitions/active-to-draw")]
    public async Task<IActionResult> TransitionActiveToDraw(int id)
    {
        try { return Ok(await _svc.TransitionActiveToDrawAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Judge,HeadJudge,Admin")]
    [HttpPatch("{id:int}/transitions/pending-to-bye")]
    public async Task<IActionResult> TransitionPendingToBYE(int id)
    {
        try { return Ok(await _svc.TransitionPendingToBYEAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/completed-to-active")]
    public async Task<IActionResult> TransitionCompletedToActive(int id)
    {
        try { return Ok(await _svc.TransitionCompletedToActiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/draw-to-active")]
    public async Task<IActionResult> TransitionDrawToActive(int id)
    {
        try { return Ok(await _svc.TransitionDrawToActiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/bye-to-active")]
    public async Task<IActionResult> TransitionBYEToActive(int id)
    {
        try { return Ok(await _svc.TransitionBYEToActiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
