# Narrative - a Rails template

> **nar·ra·tive** (_noun_) — a spoken or written account of connected events; a story.

## Overview

This template consists of a few patterns overlayed on top of Rails. Explore the [ARCHITECTURE.md](example_app/ARCHITECTURE.md) of the [example_app](example_app) to see what they are.

## Usage

Start a new rails app with the latest release.

```shell
rails new my_app -m https://github.com/maxim/narrative/releases/latest/download/narrative.rb
```

Check [releases](https://github.com/maxim/narrative/releases) if you'd like to pick an older one.

## Philosophy

Narrative-centric approach promotes the idea that your codebase should be telling short stories in your app's entry routines. All the major business actions should be visible at this level. The opposite of a narrative-centric would be model-centric, where your entry points contain a single call into a core model, and the rest of the story is hidden in callbacks. See [Rails — narrative vs model centric approach](https://max.engineer/rails-narratives-vs-models) for some unpacking.

This template follows the following principles to help make clear narratives:

1. **DIY over reusable legacy code** — instead of giving you more framework to learn, this template only adds a few well-documented patterns that you and your team are encouraged to follow yourselves. Almost nothing here adds functionality or hooks into Rails itself, and therefore doesn't inhibit Rails upgradeability.
2. **Good constructors** — perform most data transformation, filtering, and coersion in constructor methods. All struct objects introduced by this template are read only, but you can add constructors such as `from_something` to build them from all kinds of other data. In the end, these constructors will always call `.new` with the final attributes of the object itself. This practice is facilitated via the use of [portrayal gem](https://github.com/maxim/portrayal).
3. **Split abstractions on IO**[^1] — always split network calls, database calls, filesystem access, ENV access, and similar actions into standalone function calls directly from your entry points (i.e. "shell" code). Do not tangle them into core logic. Examples of entry points are: controller actions, rake tasks (and other CLI tools), background job actions. You could designate more entry points, depending on your app's interfaces.
4. **Routines over rich callbacks** — unlike Basecamp's approach, narrative approach promotes the use of transactions in your controllers. When you need to be sure that multiple actions are performed together, wrap them into a transaction block (the helper is provided by this template). Not all callbacks are bad. It's still okay to use them for attribute preparations (`before_*`), and additional db requests tied intimately to the same model/operation. For more information on the difference in approach see [Rails — narrative vs model centric approach](https://max.engineer/rails-narratives-vs-models).
5. **Strict view arguments** — Each controller action must provide at most one page object to the view. Everything that the view needs must be in that object. Don't place god objects, such as ActiveRecord models into the page, it would defeat the purpose. The only values you should allow are primitive types (strings, numbers, etc), and container types (arrays, hashes, structs, other page objects) which themselves have the same restriction. A good rule of thumb is that the entire thing should be JSON-serializable. For more info on what should go into page objects, see [Don’t Build A General Purpose API To Power Your Own Front End](https://max.engineer/server-informed-ui).
6. **Readability over consistency** — although this template comes with [standard gem](https://github.com/testdouble/standardrb) and [rubocop](https://github.com/rubocop/rubocop), the rules are relaxed to allow for more expressiveness in your code. It's useful to have some guardrails, but most spacing and alignment is left up to case-by-case readability consideration. These rules are likely to get further relaxed over time. See [Writing Maintainable Code is a Communication Skill](https://max.engineer/maintainable-code) for my views on code maintainability. The "How" part is especially relevant here.

## Additional notes

Rubocop will find a couple of issues out of the box. I recommend autocorrecting them.

---

[^1]: There's nothing specific in the template that makes you follow this principle, but it is how you end up with proper steps in your narratives.
