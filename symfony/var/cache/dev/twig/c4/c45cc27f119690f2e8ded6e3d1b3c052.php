<?php

use Twig\Environment;
use Twig\Error\LoaderError;
use Twig\Error\RuntimeError;
use Twig\Extension\CoreExtension;
use Twig\Extension\SandboxExtension;
use Twig\Markup;
use Twig\Sandbox\SecurityError;
use Twig\Sandbox\SecurityNotAllowedTagError;
use Twig\Sandbox\SecurityNotAllowedFilterError;
use Twig\Sandbox\SecurityNotAllowedFunctionError;
use Twig\Source;
use Twig\Template;
use Twig\TemplateWrapper;

/* @NelmioApiDoc/Scalar/index.html.twig */
class __TwigTemplate_a4af4f7c68717abf5697054caf770c49 extends Template
{
    private Source $source;
    /**
     * @var array<string, Template>
     */
    private array $macros = [];

    public function __construct(Environment $env)
    {
        parent::__construct($env);

        $this->source = $this->getSourceContext();

        $this->parent = false;

        $this->blocks = [
            'meta' => [$this, 'block_meta'],
            'title' => [$this, 'block_title'],
            'swagger_ui' => [$this, 'block_swagger_ui'],
            'swagger_initialization' => [$this, 'block_swagger_initialization'],
        ];
    }

    protected function doDisplay(array $context, array $blocks = []): iterable
    {
        $macros = $this->macros;
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f = $this->extensions["Symfony\\Bridge\\Twig\\Extension\\ProfilerExtension"];
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->enter($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof = new \Twig\Profiler\Profile($this->getTemplateName(), "template", "@NelmioApiDoc/Scalar/index.html.twig"));

        // line 1
        yield "<!DOCTYPE html>
<html>
<head>
    ";
        // line 4
        yield from $this->unwrap()->yieldBlock('meta', $context, $blocks);
        // line 8
        yield "    <title>";
        yield from $this->unwrap()->yieldBlock('title', $context, $blocks);
        yield "</title>
</head>
<body>
    ";
        // line 11
        yield from $this->unwrap()->yieldBlock('swagger_ui', $context, $blocks);
        // line 14
        yield "    ";
        yield from $this->unwrap()->yieldBlock('swagger_initialization', $context, $blocks);
        // line 22
        yield "</body>
</html>
";
        
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->leave($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof);

        yield from [];
    }

    // line 4
    /**
     * @return iterable<null|scalar|\Stringable>
     */
    public function block_meta(array $context, array $blocks = []): iterable
    {
        $macros = $this->macros;
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f = $this->extensions["Symfony\\Bridge\\Twig\\Extension\\ProfilerExtension"];
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->enter($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof = new \Twig\Profiler\Profile($this->getTemplateName(), "block", "meta"));

        // line 5
        yield "        <meta charset=\"UTF-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">
    ";
        
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->leave($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof);

        yield from [];
    }

    // line 8
    /**
     * @return iterable<null|scalar|\Stringable>
     */
    public function block_title(array $context, array $blocks = []): iterable
    {
        $macros = $this->macros;
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f = $this->extensions["Symfony\\Bridge\\Twig\\Extension\\ProfilerExtension"];
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->enter($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof = new \Twig\Profiler\Profile($this->getTemplateName(), "block", "title"));

        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, (isset($context["swagger_data"]) || array_key_exists("swagger_data", $context) ? $context["swagger_data"] : (function () { throw new RuntimeError('Variable "swagger_data" does not exist.', 8, $this->source); })()), "spec", [], "any", false, false, false, 8), "info", [], "any", false, false, false, 8), "title", [], "any", false, false, false, 8), "html", null, true);
        
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->leave($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof);

        yield from [];
    }

    // line 11
    /**
     * @return iterable<null|scalar|\Stringable>
     */
    public function block_swagger_ui(array $context, array $blocks = []): iterable
    {
        $macros = $this->macros;
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f = $this->extensions["Symfony\\Bridge\\Twig\\Extension\\ProfilerExtension"];
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->enter($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof = new \Twig\Profiler\Profile($this->getTemplateName(), "block", "swagger_ui"));

        // line 12
        yield "        <script id=\"api-reference\" type=\"application/json\">";
        yield json_encode(CoreExtension::getAttribute($this->env, $this->source, (isset($context["swagger_data"]) || array_key_exists("swagger_data", $context) ? $context["swagger_data"] : (function () { throw new RuntimeError('Variable "swagger_data" does not exist.', 12, $this->source); })()), "spec", [], "any", false, false, false, 12), 65);
        yield "</script>
    ";
        
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->leave($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof);

        yield from [];
    }

    // line 14
    /**
     * @return iterable<null|scalar|\Stringable>
     */
    public function block_swagger_initialization(array $context, array $blocks = []): iterable
    {
        $macros = $this->macros;
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f = $this->extensions["Symfony\\Bridge\\Twig\\Extension\\ProfilerExtension"];
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->enter($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof = new \Twig\Profiler\Profile($this->getTemplateName(), "block", "swagger_initialization"));

        // line 15
        yield "        ";
        if ((($tmp =  !Twig\Extension\CoreExtension::testEmpty((isset($context["scalar_config"]) || array_key_exists("scalar_config", $context) ? $context["scalar_config"] : (function () { throw new RuntimeError('Variable "scalar_config" does not exist.', 15, $this->source); })()))) && $tmp instanceof Markup ? (string) $tmp : $tmp)) {
            // line 16
            yield "        <script>
            document.getElementById('api-reference').dataset.configuration = JSON.stringify(";
            // line 17
            yield json_encode((isset($context["scalar_config"]) || array_key_exists("scalar_config", $context) ? $context["scalar_config"] : (function () { throw new RuntimeError('Variable "scalar_config" does not exist.', 17, $this->source); })()), 65);
            yield ");
        </script>
        ";
        }
        // line 20
        yield "        ";
        yield $this->extensions['Nelmio\ApiDocBundle\Render\Html\GetNelmioAsset']->__invoke((isset($context["assets_mode"]) || array_key_exists("assets_mode", $context) ? $context["assets_mode"] : (function () { throw new RuntimeError('Variable "assets_mode" does not exist.', 20, $this->source); })()), "scalar/scalar.standalone.js");
        yield "
    ";
        
        $__internal_6f47bbe9983af81f1e7450e9a3e3768f->leave($__internal_6f47bbe9983af81f1e7450e9a3e3768f_prof);

        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "@NelmioApiDoc/Scalar/index.html.twig";
    }

    /**
     * @codeCoverageIgnore
     */
    public function getDebugInfo(): array
    {
        return array (  158 => 20,  152 => 17,  149 => 16,  146 => 15,  136 => 14,  125 => 12,  115 => 11,  98 => 8,  88 => 5,  78 => 4,  68 => 22,  65 => 14,  63 => 11,  56 => 8,  54 => 4,  49 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("<!DOCTYPE html>
<html>
<head>
    {% block meta %}
        <meta charset=\"UTF-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">
    {% endblock meta %}
    <title>{% block title %}{{ swagger_data.spec.info.title }}{% endblock title %}</title>
</head>
<body>
    {% block swagger_ui %}
        <script id=\"api-reference\" type=\"application/json\">{{ swagger_data.spec|json_encode(65)|raw }}</script>
    {% endblock swagger_ui %}
    {% block swagger_initialization %}
        {% if scalar_config is not empty %}
        <script>
            document.getElementById('api-reference').dataset.configuration = JSON.stringify({{ scalar_config|json_encode(65)|raw }});
        </script>
        {% endif %}
        {{ nelmioAsset(assets_mode, 'scalar/scalar.standalone.js') }}
    {% endblock swagger_initialization %}
</body>
</html>
", "@NelmioApiDoc/Scalar/index.html.twig", "/Users/rafalkalitowski/mm/git/card-game-platform/symfony/vendor/nelmio/api-doc-bundle/templates/Scalar/index.html.twig");
    }
}
