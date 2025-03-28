-- A Pipeline is a series of build steps
--
-- Pipelines are rendered by separate invocations to dhall-to-yaml when our
-- monorepo triage step determines it be necessary.

let Prelude = ../External/Prelude.dhall

let List/map = Prelude.List.map

let Command = ../Command/Base.dhall

let JobSpec = ./JobSpec.dhall

let Pipeline/Type = ./Type.dhall

let Config =
      { Type = { spec : JobSpec.Type, steps : List Command.Type }
      , default = { spec = JobSpec.default, steps = [] : List Command.Type }
      }

let CompoundType = { pipeline : Pipeline/Type, spec : JobSpec.Type }

let build
    : Config.Type -> CompoundType
    =     \(c : Config.Type)
      ->  let name = c.spec.name

          let buildCommand =
                    \(c : Command.Type)
                ->      c
                    //  { key =
                            let key =
                                  Prelude.Optional.fold
                                    Text
                                    c.key
                                    Text
                                    (\(k : Text) -> k)
                                    ""

                            in  Some "_${name}-${key}"
                        }

          in  { pipeline.steps =
                  List/map Command.Type Command.Type buildCommand c.steps
              , spec = c.spec
              }

in  { Config = Config
    , build = build
    , Type = Pipeline/Type
    , CompoundType = CompoundType
    }
