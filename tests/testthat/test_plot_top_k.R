context("Testing plot_top_k and predict_top_k")

test_that("plot_top_k and predict_top_k fail when they should", {
  beach_small <- beach_preferences %>%
    filter(bottom_item %in% 1:5, top_item %in% 1:5)
  beach_tc <- generate_transitive_closure(beach_small)
  beach_init_rank <- generate_initial_ranking(beach_tc)
  bmm <- compute_mallows(rankings = beach_init_rank, preferences = beach_tc,
                         nmc = 100, save_aug = TRUE)
  # Expecting error because burnin is not set
  expect_error(plot_top_k(bmm))
  expect_error(predict_top_k(bmm))

  # Expecting error because burnin > nmc
  expect_error(plot_top_k(bmm, burnin = 200))
  expect_error(plot_top_k(bmm, burnin = 100))
  bmm$burnin <- 100
  expect_error(plot_top_k(bmm))
  bmm$burnin <- "text"
  expect_error(plot_top_k(bmm))

  expect_error(predict_top_k(bmm, burnin = 200))
  expect_error(predict_top_k(bmm, burnin = 100))
  bmm$burnin <- 100
  expect_error(predict_top_k(bmm))
  bmm$burnin <- "text"
  expect_error(predict_top_k(bmm))

  bmm <- compute_mallows(rankings = beach_init_rank, preferences = beach_tc,
                         nmc = 100, save_aug = FALSE)
  # Expecting error because save_aug = FALSE
  expect_error(plot_top_k(bmm, burnin = 50))
  expect_error(predict_top_k(bmm, burnin = 50))

  # Test whether predict_top_k returns correct numbers
  bmm <- compute_mallows(rankings = beach_init_rank, preferences = beach_tc,
                         nmc = 100, save_aug = TRUE, seed = 1L)

  pred <- predict_top_k(bmm, burnin = 90, k = 3)
  expect_equal(
    pred[c(1, 10, 90, 91, 200), ],
    structure(list(assessor = c(1, 2, 18, 19, 40), item = c("Item 1",
                                                            "Item 5", "Item 5", "Item 1", "Item 5"), prob = c(1, 1, 1, 1,
                                                                                                              1)), row.names = c(NA, -5L), groups = structure(list(assessor = c(1,
                                                                                                                                                                                2, 18, 19, 40), .rows = structure(list(1L, 2L, 3L, 4L, 5L), ptype = integer(0), class = c("vctrs_list_of",
                                                                                                                                                                                                                                                                          "vctrs_vctr", "list"))), row.names = c(NA, -5L), class = c("tbl_df",
                                                                                                                                                                                                                                                                                                                                     "tbl", "data.frame"), .drop = TRUE), class = c("grouped_df",
                                                                                                                                                                                                                                                                                                                                                                                    "tbl_df", "tbl", "data.frame")
              ) )


  pred <- predict_top_k(bmm, burnin = 90, k = 5)
  expect_equal(
    head(pred),
    structure(list(assessor = c(1, 1, 1, 1, 1, 2), item = c("Item 1",
                                                            "Item 2", "Item 3", "Item 4", "Item 5", "Item 1"), prob = c(1,
                                                                                                                        1, 1, 1, 1, 1)), row.names = c(NA, -6L), groups = structure(list(
                                                                                                                          assessor = c(1, 2), .rows = structure(list(1:5, 6L), ptype = integer(0), class = c("vctrs_list_of",
                                                                                                                                                                                                             "vctrs_vctr", "list"))), row.names = c(NA, -2L), class = c("tbl_df",
                                                                                                                                                                                                                                                                        "tbl", "data.frame"), .drop = TRUE), class = c("grouped_df",
                                                                                                                                                                                                                                                                                                                       "tbl_df", "tbl", "data.frame")))

})


test_that("predict_top_k works with augmentation thinning", {
  # Create top-k dataset
  k <- 3
  dat <- potato_visual
  dat[dat > 3] <- NA
  dat <- dat[, apply(dat, 2, function(x) !all(is.na(x)))]

  # Run the model with different levels of thinning
  # This model is deterministic, because each subject has either ranked or not ranked the item
  bmm1 <- compute_mallows(rankings = dat, nmc = 500, save_aug = TRUE, aug_thinning = 1L,
                          seed = 1L)
  bmm3 <- compute_mallows(rankings = dat, nmc = 500, save_aug = TRUE, aug_thinning = 3L,
                          seed = 1L)

  pred1 <- predict_top_k(bmm1, burnin = 200, k = k)
  pred3 <- predict_top_k(bmm3, burnin = 200, k = k)

  expect_equal(pred1, pred3)
})
