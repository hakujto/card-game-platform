using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using CardsProject.Services.Content;

namespace CardsProject.Controllers.Content;

[ApiController]
[Route("api/article_comments")]
[Microsoft.AspNetCore.Authorization.AllowAnonymous]
public class ArticleCommentController : ControllerBase
{
    private readonly ArticleCommentService _svc;

    public ArticleCommentController(ArticleCommentService svc) => _svc = svc;

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var items = await _svc.GetAllAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ArticleCommentDto dto)
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

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Show(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        return Ok(entity);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var entity = await _svc.GetByIdAsync(id);
        if (entity is null) return NotFound();
        var deleted = await _svc.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpPost("{id:int}/hide")]
    public async System.Threading.Tasks.Task<IActionResult> Hide(int id)
    {
        try
        {
            await _svc.HideAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpPost("{id:int}/unhide")]
    public async System.Threading.Tasks.Task<IActionResult> Unhide(int id)
    {
        try
        {
            await _svc.UnhideAsync(id);
            return NoContent();
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }

    [HttpGet("{id:int}/is-reply")]
    public async System.Threading.Tasks.Task<IActionResult> IsReply(int id)
    {
        try
        {
            var result = await _svc.IsReplyAsync(id);
            return Ok(result);
        }
        catch (ArgumentException ex) { return UnprocessableEntity(new { error = ex.Message }); }
        catch (KeyNotFoundException) { return NotFound(); }
    }
}
