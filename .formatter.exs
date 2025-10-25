# Used by "mix format"
[
  locals_without_parens: [service: 1, service: 2],
  export: [locals_without_parens: [service: 1, service: 2]],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
