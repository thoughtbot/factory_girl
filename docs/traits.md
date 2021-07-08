Traits & factories both have a `FactoryBot::Definition` (LINK) and hold
on to attributes. (LINK to documentation on how factories work under the
hood).

Defining a trait within another trait is very similar to defining a
trait within a factory.

# Traits

## Defining & registering traits

### Global
In `FactoryBot::Syntax::Default::DSL` (LINK) there is a `trait` method that
builds a `Trait` object and registers it in the global registry.

When it comes time to use the trait, factory_bot will first look to see if
your factory has the trait defined. If it does not, factory_bot will look for
it in the global registry, in `FactoryBot::Definition#trait_by_name` (LINK).

See example in the README here: ANCHOR

### Inline
The role of `FactoryBot::DefinitionProxy` (LINK) is to take the code you
wrote and turn it into factory_bot objects, then store those objects on the
`FactoryBot::Definition` (LINK).

In the case of traits, the `FactoryBot::DefinitionProxy#trait` (LINK) method
builds and registers the `FactoryBot::Trait` (LINK) object.

See example in the README here: ANCHOR
https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#defining-traits

### WIP - Potential Glossary?

`@defined_traits` will hold all of the `FactoryBot::Trait` objects for that definition.
Global traits will exist within their own registry. (LINK ###GLOBAL)

`@base_traits` will hold all of the traits that are explicitly or implicitly defined as default traits.

`@additional_traits` will hold any override traits passed in at build time.

### Default traits

#### Explicit Traits
An example of explicit declarations can be found in the GETTING_STARTED guide #traits section.
Note where the :traits keyword argument is used in the first code example.
https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#traits

`FactoryBot::Definition` will be initialized with explicit traits, set to the `@base_traits` variable.
https://github.com/thoughtbot/factory_bot/blob/ae2fce1874260b2b2017379a142057670cc93bbe/lib/factory_bot/definition.rb#L13

#### Implicit Declaration
Implicit declarations can include defining associations, sequences or traits. [FactoryBot::Declaration::Implicit](https://github.com/thoughtbot/factory_bot/blob/master/lib/factory_bot/declaration/implicit.rb)
`FactoryBot::Factory#inherit_traits` will turn the implicit attribute into a default trait.
`FactoryBot::Factory#inherit_traits` adds more base traits to `@base_traits`.

https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#as-implicit-attributes-1

### Override traits
The Factory is cloned within `FactoryBot::Factory#with_traits` and override traits are applied in `@additional_traits`.
When the factory is cloned with the `#FactoryBot::Definition#initialize_copy`, some instance variables are cleared out.
Particularly `@defined_traits_by_name` will be reset and prior caching will be lost. This is something that can potentially
be computationally expensive when there are lots of traits.
https://github.com/thoughtbot/factory_bot/blob/ae2fce1874260b2b2017379a142057670cc93bbe/lib/factory_bot/factory_runner.rb#L16-L18

## Compiling & aggregating traits
<!-- TODO: `#compile` and `#aggregate_from_traits` -->

<!-- TODO: Parent and child factories and how they interact -->

<!-- TODO: Referring to parent/child trait and how they interact -->
  <!-- Precedence order - if attributes are defined in multiple places which one does factory_bot prioritize? -->
