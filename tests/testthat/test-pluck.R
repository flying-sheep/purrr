context("pluck")

test_that("contents must be a vector", {
  expect_error(pluck(quote(x), list(1)), "Don't know how to pluck")
})

# pluck vector --------------------------------------------------------------

test_that("can pluck by position", {
  x <- list("a", 1, c(TRUE, FALSE))

  # double
  expect_identical(pluck(x, 1), x[[1]])
  expect_identical(pluck(x, 2), x[[2]])
  expect_identical(pluck(x, 3), x[[3]])

  # integer
  expect_identical(pluck(x, 1L), x[[1]])
  expect_identical(pluck(x, 2L), x[[2]])
  expect_identical(pluck(x, 3L), x[[3]])
})

test_that("can pluck by name", {
  x <- list(a = "a", b = 1, c = c(TRUE, FALSE))

  expect_identical(pluck(x, "a"), x[["a"]])
  expect_identical(pluck(x, "b"), x[["b"]])
  expect_identical(pluck(x, "c"), x[["c"]])
})

test_that("can pluck from atomic vectors", {
  expect_identical(pluck(TRUE, 1), TRUE)
  expect_identical(pluck(1L, 1), 1L)
  expect_identical(pluck(1, 1), 1)
  expect_identical(pluck("a", 1), "a")
})

test_that("can pluck by name and position", {
  x <- list(a = list(list(b = 1)))
  expect_equal(pluck(x, "a", 1, "b"), 1)
})


test_that("require length 1 vectors", {
  expect_error(pluck(1, letters), "must have length 1")
  expect_error(pluck(1, TRUE), "must be a character or numeric")
})

test_that("special indexes never match", {
  x <- list(a = 1, b = 2, c = 3)

  expect_null(pluck(x, NA_character_))
  expect_null(pluck(x, ""))

  expect_null(pluck(x, NA_integer_))

  expect_null(pluck(x, NA_real_))
  expect_null(pluck(x, NaN))
  expect_null(pluck(x, Inf))
  expect_null(pluck(x, -Inf))
})

test_that("special values return NULL", {
  # unnamed input
  expect_null(pluck(list(1, 2), "a"))

  # zero length input
  expect_null(pluck(integer(), 1))

  # past end
  expect_null(pluck(1:4, 10))
  expect_null(pluck(1:4, 10L))
})

test_that("handles weird names", {
  x <- list(1, 2, 3, 4, 5)
  names(x) <- c("a", "a", NA, "", "b")

  expect_equal(pluck(x, "a"), 1)
  expect_equal(pluck(x, "b"), 5)

  expect_null(pluck(x, ""))
  expect_null(pluck(x, NA_character_))
})

test_that("supports splicing", {
  x <- list(list(bar = 1, foo = 2))
  idx <- list(1, "foo")
  expect_identical(pluck(x, !!!idx), 2)
})


# closures ----------------------------------------------------------------

test_that("can pluck attributes", {
  x <- structure(
    list(
      structure(
        list(),
        x = 1
      )
    ),
    y = 2
  )

  expect_equal(pluck(x, attr_getter("y")), 2)
  expect_equal(pluck(x, 1, attr_getter("x")), 1)
})

test_that("attr_getter() evaluates eagerly", {
  getters <- list_len(2)
  attrs <- c("foo", "bar")
  for (i in seq_along(attrs)) {
    getters[[i]] <- attr_getter(attrs[[i]])
  }

  x <- set_attrs(list(), foo = "foo", bar = "bar")
  expect_identical(getters[[1]](x), "foo")
})

test_that("delegate error handling to Rf_eval()", {
  expect_error(pluck(letters, function() NULL), "unused argument")
  expect_error(pluck(letters, function(x, y) y), "missing, with no default")
})


# attribute extraction ----------------------------------------------------

test_that("attr_getter() uses exact (non-partial) matching", {
  x <- 1
  attr(x, "labels") <- "foo"

  expect_identical(attr_getter("labels")(x), "foo")
  expect_identical(attr_getter("label")(x), NULL)
})


# environments ------------------------------------------------------------

test_that("pluck errors with invalid indices", {
  expect_error(pluck(environment(), 1), "not a string")
  expect_error(pluck(environment(), letters), "not a string")
})

test_that("pluck returns missing with missing index", {
  expect_equal(pluck(environment(), NA_character_), NULL)
})

test_that("plucks by name", {
  env <- new.env(parent = emptyenv())
  env$x <- 10

  expect_equal(pluck(env, "x"), 10)
})


# S4 ----------------------------------------------------------------------

newA <- methods::setClass("A", list(a = "numeric", b = "numeric"))
A <- newA(a = 1, b = 10)

test_that("pluck errors with invalid indices", {
  expect_error(pluck(A, 1), "not a string")
  expect_error(pluck(A, letters), "not a string")
})

test_that("pluck returns missing with missing index", {
  expect_equal(pluck(A, NA_character_), NULL)
})

test_that("plucks by name", {
  expect_equal(pluck(A, "a"), 1)
})

test_that("can't pluck from complex", {
  expect_error( pluck( 1+2i, 1 ), "Don't know how to index object of type complex at level 1" )
})
