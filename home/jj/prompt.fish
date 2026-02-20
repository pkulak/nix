# From: https://gist.github.com/hroi/d0dc0e95221af858ee129fd66251897e

# Are we in a jj repo?
if not jj root --quiet &>/dev/null
  return 1
end

# Generate prompt
jj log --ignore-working-copy --no-graph --color always -r @ -T '
  separate(
    " ",
    bookmarks.join(", "),
    coalesce(
      surround(
        "\"",
        "\"",
        if(
          description.first_line().substr(0, 24).starts_with(description.first_line()),
          description.first_line().substr(0, 24),
          description.first_line().substr(0, 23) ++ "…"
        )
      ),
      "~"
    ),
    if(conflict, "(conflict)"),
    if(empty, "(empty)"),
    if(divergent, "(divergent)"),
    if(hidden, "(hidden)"),
  )
'
