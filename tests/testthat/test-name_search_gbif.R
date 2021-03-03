test_that("non-plant name returns no match", {
  name_result <- name_search_gbif("dfsd sdfsd")

  expect_equal(name_result$confidence, "no_match")
})
