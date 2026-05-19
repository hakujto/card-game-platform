using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Content;
using Stream = CardsProject.Domain.Content.Stream;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/streams")]
public class StreamController : ControllerBase
{
    private readonly StreamService _svc;

    public StreamController(StreamService svc) => _svc = svc;

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] StreamDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        try
        {
            var entity = await _svc.CreateAsync(dto);
            return CreatedAtAction(nameof(Show), new { id = entity.Id }, entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] StreamDto dto)
    {
        try
        {
            var entity = await _svc.UpdateAsync(id, dto);
            if (entity is null) return NotFound();
            return Ok(entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _svc.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpPost("{id:int}/live")]
    public async System.Threading.Tasks.Task<IActionResult> GoLive(int id)
    {
        try
        {
            await _svc.GoLiveAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/end")]
    public async System.Threading.Tasks.Task<IActionResult> End(int id)
    {
        try
        {
            await _svc.EndAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/viewers")]
    public async System.Threading.Tasks.Task<IActionResult> UpdateViewerPeak(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var count = (int)body["count"];
            await _svc.UpdateViewerPeakAsync(id, count);
            return NoContent();
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/duration")]
    public async System.Threading.Tasks.Task<IActionResult> DurationMinutes(int id)
    {
        try
        {
            var result = await _svc.DurationMinutesAsync(id);
            return Ok(result);
        }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Streamer")]
    [HttpPatch("{id:int}/transitions/scheduled-to-live")]
    public async Task<IActionResult> TransitionScheduledToLive(int id)
    {
        try { return Ok(await _svc.TransitionScheduledToLiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Streamer")]
    [HttpPatch("{id:int}/transitions/live-to-ended")]
    public async Task<IActionResult> TransitionLiveToEnded(int id)
    {
        try { return Ok(await _svc.TransitionLiveToEndedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/ended-to-live")]
    public async Task<IActionResult> TransitionEndedToLive(int id)
    {
        try { return Ok(await _svc.TransitionEndedToLiveAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
