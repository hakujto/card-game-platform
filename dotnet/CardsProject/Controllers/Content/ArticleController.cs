using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/articles")]
public class ArticleController : ControllerBase
{
    private readonly ArticleService _svc;

    public ArticleController(ArticleService svc) => _svc = svc;

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string? q = null)
    {
        var items = await _svc.SearchAsync(q);
        return Ok(items);
    }

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ArticleDto dto)
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

    [Microsoft.AspNetCore.Authorization.AllowAnonymous]
    [HttpPut("{id:int}")]
    [HttpPatch("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ArticleDto dto)
    {
        var existing = await _svc.GetByIdAsync(id);
        if (existing is null) return NotFound();
        try
        {
            var entity = await _svc.UpdateAsync(id, dto);
            if (entity is null) return NotFound();
            return Ok(entity);
        }
        catch (ValidationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { error = ex.Message }); }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) { return BadRequest(new { error = ex.InnerException?.Message ?? ex.Message }); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "editor,admin")]
    [HttpPost("{id:int}/publish")]
    public async System.Threading.Tasks.Task<IActionResult> Publish(int id)
    {
        try
        {
            await _svc.PublishAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "editor,admin")]
    [HttpPost("{id:int}/archive")]
    public async System.Threading.Tasks.Task<IActionResult> Archive(int id)
    {
        try
        {
            await _svc.ArchiveAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "editor,admin")]
    [HttpPut("{id:int}/replace")]
    public async System.Threading.Tasks.Task<IActionResult> Replace(int id, [FromBody] System.Collections.Generic.Dictionary<string, object> body)
    {
        try
        {
            var data = (string)body["data"];
            var result = await _svc.ReplaceAsync(id, data);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/view")]
    public async System.Threading.Tasks.Task<IActionResult> IncrementView(int id)
    {
        try
        {
            await _svc.IncrementViewAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/like")]
    public async System.Threading.Tasks.Task<IActionResult> Like(int id)
    {
        try
        {
            await _svc.LikeAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpDelete("{id:int}/like")]
    public async System.Threading.Tasks.Task<IActionResult> Unlike(int id)
    {
        try
        {
            await _svc.UnlikeAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/reading-time")]
    public async System.Threading.Tasks.Task<IActionResult> ReadingTimeMinutes(int id)
    {
        try
        {
            var result = await _svc.ReadingTimeMinutesAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Editor,Admin")]
    [HttpPatch("{id:int}/transitions/draft-to-published")]
    public async Task<IActionResult> TransitionDraftToPublished(int id)
    {
        try { return Ok(await _svc.TransitionDraftToPublishedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Editor,Admin")]
    [HttpPatch("{id:int}/transitions/published-to-archived")]
    public async Task<IActionResult> TransitionPublishedToArchived(int id)
    {
        try { return Ok(await _svc.TransitionPublishedToArchivedAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [Microsoft.AspNetCore.Authorization.Authorize(Roles = "Admin")]
    [HttpPatch("{id:int}/transitions/archived-to-draft")]
    public async Task<IActionResult> TransitionArchivedToDraft(int id)
    {
        try { return Ok(await _svc.TransitionArchivedToDraftAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPatch("{id:int}/transitions/published-to-draft")]
    public async Task<IActionResult> TransitionPublishedToDraft(int id)
    {
        try { return Ok(await _svc.TransitionPublishedToDraftAsync(id)); }
        catch (InvalidOperationException ex) { return Conflict(new { error = ex.Message }); }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
