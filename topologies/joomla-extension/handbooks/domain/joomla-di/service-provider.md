---
paths:
  - "**/services/provider.php"
  - "**/Extension/**"
  - "**/src/Extension/**"
---

# Handbook: Joomla Service Provider — wire the extension correctly

**Scope:** PRs touching the DI service provider or the Extension class.
**Enforcement:** advisory.

## The rule

Every Joomla extension registers itself in Joomla's DI container through `services/provider.php`. This file is the single wiring point — it tells Joomla how to initialise the extension, which services it requires, and how they should be provided.

| Required | Pattern |
|---|---|
| Component provider | Register under `ComponentInterface::class`; implement `BootableExtensionInterface` if the component needs boot-time setup |
| Plugin provider | Register under `PluginInterface::class`; use `PluginHelper::getPlugin()` only in legacy paths |
| MVCFactory registration | `$container->registerServiceProvider(new MVCFactory('\\Vendor\\Component\\Name'));` |
| Dispatcher registration | `$container->registerServiceProvider(new DispatcherFactory('\\Vendor\\Component\\Name'));` |
| Database injection | Get `DatabaseInterface::class` from the container; never use `Factory::getDbo()` (deprecated since Joomla 4.3, removed in 7.0) |
| Router registration | For components with SEF URLs: register `RouterFactoryInterface::class` |

| Anti-pattern | Why it's broken |
|---|---|
| `Factory::getDbo()` or `Factory::getApplication()` in extension code | Deprecated; bypasses DI; untestable |
| `new ModelClass()` inside a controller | Bypasses MVCFactory; the model won't get its dependencies injected |
| Hardcoded class names in `provider.php` instead of interface bindings | Can't swap implementations for testing |
| `$container->get()` deep inside business logic | Service locator pattern; hides dependencies; prefer constructor injection |
| Missing `ComponentInterface` registration | Extension silently fails to load; Joomla falls back to a generic error |

## Why

Joomla 4+ introduced a proper DI container (based on `Joomla\DI\Container`). The service provider is how extensions participate. Skipping it means the extension either uses deprecated static factories (which will be removed in Joomla 7) or constructs dependencies manually (untestable, brittle).

The Extension class (`src/Extension/ExampleComponent.php`) is the public face — it retrieves services from the container registered by `provider.php` and exposes them to the MVC layer. Getting this wiring right means models, views, and controllers all receive their dependencies through factories, making the entire extension testable and mockable.

## What Rex flags

Surface a finding when:

1. Extension code uses `Factory::getDbo()`, `Factory::getApplication()`, or other deprecated `Factory::get*()` methods.
2. A controller or model instantiates another MVC class directly (`new ItemModel()`) instead of using `$this->getMVCFactory()->createModel()` or `$this->getModel()`.
3. `services/provider.php` doesn't register `ComponentInterface::class` (for components) or `PluginInterface::class` (for plugins).
4. The Extension class doesn't implement `BootableExtensionInterface` when it performs boot-time setup (event subscriptions, category registration).
5. `$container->get(SomeClass::class)` is called inside a Model or Controller — should receive the dependency via constructor/method injection.
6. A new service is added but not registered in `provider.php`.

## Sample finding

> **Service provider (Joomla)** — `src/Model/ItemModel.php:15` calls `Factory::getDbo()` to get a database connection. This method is deprecated since Joomla 4.3 and will be removed in 7.0. The model should receive `DatabaseInterface` through the MVCFactory, which injects it automatically when the model is created via `$this->getModel('Item')` in the controller.
>
> **Service provider (Joomla)** — `services/provider.php` registers the MVCFactory but doesn't register `RouterFactoryInterface`. The component's SEF URLs won't resolve. Add `$container->registerServiceProvider(new RouterFactory(...))`.

## What's NOT a violation

- `Factory::getApplication()` in a legacy entry point being migrated incrementally — flag as advisory with a migration note.
- Using `$app = $this->getApplication()` in a plugin's event handler — plugins receive the application through their constructor; `getApplication()` is the correct accessor.
- `$container->get()` inside `services/provider.php` itself — that's the wiring point; service locator is expected there.
- CLI commands using `Factory::getContainer()` at the top level — CLI bootstrap doesn't have an alternative injection point.

## Pattern — the standard component service provider

```php
<?php

declare(strict_types=1);

// services/provider.php

defined('_JEXEC') or die;

use Joomla\CMS\Dispatcher\ComponentDispatcherFactoryInterface;
use Joomla\CMS\Extension\ComponentInterface;
use Joomla\CMS\Extension\Service\Provider\ComponentDispatcherFactory;
use Joomla\CMS\Extension\Service\Provider\MVCFactory;
use Joomla\CMS\Extension\Service\Provider\RouterFactory;
use Joomla\CMS\MVC\Factory\MVCFactoryInterface;
use Joomla\DI\Container;
use Joomla\DI\ServiceProviderInterface;
use Vendor\Component\Example\Administrator\Extension\ExampleComponent;

return new class () implements ServiceProviderInterface {
    public function register(Container $container): void
    {
        $container->registerServiceProvider(new MVCFactory('\\Vendor\\Component\\Example'));
        $container->registerServiceProvider(new ComponentDispatcherFactory('\\Vendor\\Component\\Example'));
        $container->registerServiceProvider(new RouterFactory('\\Vendor\\Component\\Example'));

        $container->set(
            ComponentInterface::class,
            function (Container $container) {
                $component = new ExampleComponent(
                    $container->get(ComponentDispatcherFactoryInterface::class)
                );
                $component->setMVCFactory($container->get(MVCFactoryInterface::class));

                return $component;
            }
        );
    }
};
```

---

*Part of [ApexYard](https://github.com/me2resh/apexyard) — multi-project SDLC framework for Claude Code · MIT.*
