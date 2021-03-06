# Used by "mix format"

locals_without_parens = [
  table: 1,
  add: 1,
  add: 2,
  add: 3,
  create: 1,
  unique_index: 2,
  from: 2
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test,priv}/**/*.{ex,exs}"],
  import_deps: [:ecto],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
