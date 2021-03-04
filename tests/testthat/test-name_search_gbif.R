test_that("non-plant name returns no match", {
  name_result <- name_search_gbif("dfsd sdfsd")

  expect_equal(name_result$confidence, NA_integer_)
})

test_that("ambiguous name returns no match", {
  match <- name_search_gbif("Poa an")

  expect_equal(match$confidence, NA_integer_)
})
