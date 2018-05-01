context("Cube subsets")

test_that("replaceMissingWithTRUE", {
    expect_identical(replaceMissingWithTRUE(alist(, 1)),
        list(TRUE, 1))
    expect_error(replaceMissingWithTRUE(alist(, non_object))[[2]],
        "object 'non_object' not found")
})

cat_x_mr_x_mr <- loadCube(test_path("cubes/cat-x-mr-x-mr.json"))
catarray_x_mr <- loadCube(test_path("cubes/catarray-x-mr.json"))

test_that("subsetArrayDimension categorical dimension", {
    expected <- list(
        name = c("cats", "No Data"),
        any.or.none = c(FALSE, FALSE
        ),
        missing = c(FALSE, TRUE),
        references = list(
            alias = "animal",
            name = "animal",
            type = "categorical",
            categories = list(
                list(numeric_value = 1L,
                    missing = FALSE,
                    id = 1L, name = "cats"),
                list(numeric_value = NULL,
                    missing = TRUE,
                    id = -1L,
                    name = "No Data")
            )
        )
    )
    expect_identical(subsetArrayDimension(cat_x_mr_x_mr@dims[[1]], 1:2), expected)
})

test_that("subsetArrayDimension MR dimension", {
    expected <- list(
        name = c("rest_opinion","play_opinion"),
        any.or.none = c(FALSE, FALSE),
        missing = c(FALSE, FALSE),
        references = list(
            description = "",
            format = list(
                summary = list(digits = 0L)
            ),
            subreferences = list(
                "rest_opinion#" = list(alias = "rest_opinion#", name = "rest_opinion"),
                "play_opinion#" = list(alias = "play_opinion#", name = "play_opinion")
            ),
            notes = "",
            name = "opinion MR",
            discarded = FALSE,
            alias = "opinion_mr",
            view = list(
                show_counts = FALSE,
                include_missing = FALSE,
                column_width = NULL
            ),
            type = "subvariable_items",
            subvariables = c("food_opinion#/", "rest_opinion#/", "play_opinion#/")
        )
    )
    expect_identical(subsetArrayDimension(cat_x_mr_x_mr@dims[[2]], 2:3), expected)
})

test_that("subsetArrayDimension categorical array dimension", {
    expected <- list(
        name = c("cat_feeling"),
        any.or.none = c(FALSE),
        missing = c(FALSE),
        references = list(
            subreferences = list(
                "cat_feeling" = list(alias = "cat_feeling", name = "cat_feeling")
            ),
            name = "feeling CA",
            alias = "feeling_ca",
            type = "subvariable_items",
            subvariables = c("cat_feeling/", "dog_feeling/")
        )
    )
    expect_identical(subsetArrayDimension(catarray_x_mr@dims[[1]], 1), expected)

    expected <- list(
        name = c("Somewhat Happy", "Neutral"),
        any.or.none = c(FALSE, FALSE),
        missing = c(FALSE, FALSE),
        references = list(
            subreferences = list(
                "cat_feeling" = list(alias = "cat_feeling", name = "cat_feeling"),
                "dog_feeling" = list(alias = "dog_feeling", name = "dog_feeling")
            ),
            name = "feeling CA",
            alias = "feeling_ca",
            type = "categorical",
            subvariables = c("cat_feeling/", "dog_feeling/"),
            categories = list(
                list(numeric_value = 2L,
                     id = 2L,
                     name = "Somewhat Happy",
                     missing = FALSE),
                list(numeric_value = 3L,
                     id = 3L,
                     name = "Neutral",
                     missing = FALSE)
            )
        )
    )
    expect_identical(subsetArrayDimension(catarray_x_mr@dims[[2]], c(2:3)), expected)
})

test_that("translateCubeIndex", {
    expect_identical(translateCubeIndex(cat_x_mr_x_mr, alist(1, ,), drop = FALSE),
        alist(1, , TRUE, , TRUE))
    expect_identical(translateCubeIndex(cat_x_mr_x_mr, alist(1:2, 1:2, 1:2), drop = FALSE),
        alist(1:2, 1:2, TRUE, 1:2, TRUE))
    expect_identical(translateCubeIndex(cat_x_mr_x_mr, alist(1:2, 1, 2), drop = FALSE),
        alist(1:2, 1, TRUE, 2, TRUE))
    # MR selection entries are set to index 1 when the indicator is dropped
    expect_identical(translateCubeIndex(cat_x_mr_x_mr, alist(1:2, 1, 2), drop = TRUE),
        alist(1:2, 1, "mr_select_drop", 2, "mr_select_drop"))
    expect_identical(
        translateCubeIndex(cat_x_mr_x_mr,
            alist(c(TRUE, FALSE, TRUE), c(TRUE, FALSE, TRUE), c(TRUE, FALSE) ), drop = TRUE),
        alist(c(TRUE, FALSE, TRUE), c(TRUE, FALSE, TRUE), TRUE,c(TRUE, FALSE), TRUE))
})

test_that("cube [ method errors correctly", {
    cube <- cat_x_mr_x_mr
    expect_equal(length(dim(cube)), 3)
    expect_error(cube[1,2,3,4,5,6],
                 paste0("You must supply 3 dimensions to subset a 3 ",
                        "dimensional cube; you supplied 6."))
    err <- paste0(c("Invalid subset:",
        "- At position 1 you tried to select element 3 when the dimension has 2 elements.",
        "- At position 2 you tried to select element 4 when the dimension has 3 elements."),
        collapse = "\n")
    expect_error(cube[3, 4, 1], err)
    expect_error(cube[rep(TRUE, 3), 4 , 1], err)
    expect_silent(showMissing(cube)[3, 1, 1])
})

test_that("[ method for cat by cat cubes", {

    cube <- cube_withNA <- loadCube(test_path("cubes/cat-x-cat.json"))
    cube_withNA@useNA <- "always"

    subset_cube <- showMissing(cube)[1:2,] # drop the No Data row
    expect_is(subset_cube, "CrunchCube")
    expect_equal(dim(subset_cube), c(2, 4))

    expect_equal(dim(subset_cube), c(2, 4))
    expect_equal(as.array(subset_cube), as.array(showMissing(cube))[1:2, ])

    # drop a non-missing row
    subset_cube <- cube[1, , drop = FALSE] # drop the second row (C)
    expect_is(subset_cube, "CrunchCube")
    expect_equal(dim(subset_cube), c(1, 2))

    # since the cube retains the missing dimension, it defaults behavior to
    # `drop = FALSE`, though this isn't true of the the array since only one
    # element is being selected from that dimension
    expect_equal(as.array(subset_cube), as.array(cube)[1, , drop = FALSE])

    # check that useNA doesn't impact
    subset_cube_withNA <- cube_withNA[c(1, 3),] # drop the second row (C)
    expect_equal(as.array(subset_cube_withNA), as.array(cube_withNA)[c(1, 3),])

    # drop, selecting a missing category on columns
    drop_cube <- cube[1:2, 1:2]
    expect_is(subset_cube, "CrunchCube")
    expect_equal(dim(drop_cube), c(2, 2))

    expect_equal(as.array(drop_cube), as.array(cube)[1:2, 1:2, drop = FALSE])

    # no drop, selecting a missing category on columns
    no_drop_cube <- cube[1, 1:2, drop = FALSE]
    expect_is(no_drop_cube, "CrunchCube")
    expect_equal(dim(no_drop_cube), c(1, 2))
    expect_equal(as.array(no_drop_cube), as.array(cube)[1, 1:2, drop = FALSE])

})

test_that("[ method for MR cubes", {
    cat_x_mr_x_mr_withNA <- cat_x_mr_x_mr
    cat_x_mr_x_mr_withNA@useNA <- "always"
    # subset rows
    # drop the No Data row which is #2 here! d
    subset_cat_x_mr_x_mr <- showMissing(cat_x_mr_x_mr)[c(1,3), , ]
    expect_is(subset_cat_x_mr_x_mr, "CrunchCube")
    expect_equal(dim(subset_cat_x_mr_x_mr), c(2, 3, 2))
    expect_equal(as.array(subset_cat_x_mr_x_mr), as.array(cat_x_mr_x_mr)[1:2, , ])

    subset_cat_x_mr_x_mr_withNA <- cat_x_mr_x_mr_withNA[c(1, 3), , ]
    expect_equal(as.array(subset_cat_x_mr_x_mr_withNA), as.array(cat_x_mr_x_mr_withNA)[c(1, 3), , ])
    subset_cat_x_mr_x_mr_withNA <- cat_x_mr_x_mr_withNA[c(1, 2), , ]
    expect_equal(as.array(subset_cat_x_mr_x_mr_withNA), as.array(cat_x_mr_x_mr_withNA)[c(1, 2), , ])

    # subset cols
    # drop the No Data row which is #2 here!
    subset_cat_x_mr_x_mr <- cat_x_mr_x_mr[, c(1,3), ]
    expect_is(subset_cat_x_mr_x_mr, "CrunchCube")
    expect_equal(dim(showMissing(subset_cat_x_mr_x_mr)), c(3, 2, 2))

    expect_equal(as.array(subset_cat_x_mr_x_mr), as.array(cat_x_mr_x_mr)[, c(1,3), ])

    subset_cat_x_mr_x_mr_withNA <- cat_x_mr_x_mr_withNA[, c(1, 3), ]
    expect_equal(as.array(subset_cat_x_mr_x_mr_withNA), as.array(cat_x_mr_x_mr_withNA)[, c(1, 3), ])
    subset_cat_x_mr_x_mr_withNA <- cat_x_mr_x_mr_withNA[, c(1, 2), ]
    expect_equal(as.array(subset_cat_x_mr_x_mr_withNA), as.array(cat_x_mr_x_mr_withNA)[, c(1, 2), ])

    # subset cols with drop
    subset_cat_x_mr_x_mr <- cat_x_mr_x_mr[, 3, ]
    expect_is(subset_cat_x_mr_x_mr, "CrunchCube")
    expect_equal(dim(subset_cat_x_mr_x_mr), c(2, 2))
    expect_equal(as.array(subset_cat_x_mr_x_mr), as.array(cat_x_mr_x_mr)[, 3, ])

    subset_cat_x_mr_x_mr_withNA <- cat_x_mr_x_mr_withNA[, 3, ]
    expect_equal(as.array(subset_cat_x_mr_x_mr_withNA), as.array(cat_x_mr_x_mr_withNA)[, 3, ])
    subset_cat_x_mr_x_mr_withNA <- cat_x_mr_x_mr_withNA[, 2, ]
    expect_equal(as.array(subset_cat_x_mr_x_mr_withNA), as.array(cat_x_mr_x_mr_withNA)[, 2, ])

    # subset slices
    subset_cat_x_mr_x_mr <- cat_x_mr_x_mr[, , 2]
    expect_is(subset_cat_x_mr_x_mr, "CrunchCube")
    expect_equal(dim(subset_cat_x_mr_x_mr), c(2, 3))
    expect_equal(as.array(subset_cat_x_mr_x_mr), as.array(cat_x_mr_x_mr)[, , 2])

    subset_cat_x_mr_x_mr_withNA <- cat_x_mr_x_mr_withNA[, , 2]
    expect_equal(as.array(subset_cat_x_mr_x_mr_withNA), as.array(cat_x_mr_x_mr_withNA)[, , 2])
})

test_that("[ method for cat array cubes", {
    cube <- cube_withNA <- loadCube(test_path("cubes/catarray-x-cat.json"))
    cube_withNA@useNA <- "always"

    # subset rows
    # drop the No Data row which is #2 here!
    subset_cube <- cube[2, , ]
    expect_is(subset_cube, "CrunchCube")
    expect_equal(dim(subset_cube), c(5, 2))
    expect_equal(as.array(subset_cube), as.array(cube)[2, , ])

    subset_cube_withNA <- cube_withNA[2, , ]
    expect_equal(as.array(subset_cube_withNA), as.array(cube_withNA)[2, , ])

    # subset cols
    subset_cube <- cube[, c(1,3), ]
    expect_is(subset_cube, "CrunchCube")
    expect_equal(dim(subset_cube), c(2, 2, 2))
    expect_equal(as.array(subset_cube), as.array(cube)[, c(1,3), ])

    subset_cube_withNA <- cube_withNA[, c(1, 3), ]
    expect_equal(as.array(subset_cube_withNA), as.array(cube_withNA)[, c(1, 3), ])
    subset_cube_withNA <- cube_withNA[, c(1, 2), ]
    expect_equal(as.array(subset_cube_withNA), as.array(cube_withNA)[, c(1, 2), ])

    # subset cols with drop
    subset_cube <- cube[, 3, ]
    expect_is(subset_cube, "CrunchCube")
    expect_equal(dim(subset_cube), c(2, 2))
    expect_equal(as.array(subset_cube), as.array(cube)[, 3, ])

    subset_cube_withNA <- cube_withNA[, 3, ]
    expect_equal(as.array(subset_cube_withNA), as.array(cube_withNA)[, 3, ])


    # subset slices
    subset_cube <- cube[, , 1:2]
    expect_is(subset_cube, "CrunchCube")
    expect_equal(dim(subset_cube), c(2, 5, 2))
    expect_equal(dim(showMissing(subset_cube)), c(2, 6, 2))
    expect_equal(as.array(subset_cube), as.array(cube)[, , 1:2])

    subset_cube_withNA <- cube_withNA[, , 1:2]
    expect_equal(as.array(subset_cube_withNA), as.array(cube_withNA)[, , 1:2])
})

test_that("subsetting works when @useNA == 'ifany'", {
    cube <- loadCube("cubes/univariate-categorical.json")
    expect_equal(dim(cube), 2)
    cube_ifany <- showIfAny(cube)
    expect_equal(dim(cube_ifany), 3)
    expect_equal(as.array(cube_ifany[1]), as.array(cube_ifany)[1])
    expect_equal(as.array(cube_ifany[1:2]), as.array(cube_ifany)[1:2])

    #multivariate
    cube <- loadCube("cubes/cat-x-cat.json")
    expect_equal(dim(cube), c(2,2))
    cube_ifany <- showIfAny(cube)
    expect_equal(dim(cube_ifany), c(2,3))
    expect_equal(as.array(cube_ifany[1:2, ]), as.array(cube_ifany)[1:2, ])
    expect_equal(as.array(cube_ifany[1:2, 1]), as.array(cube_ifany)[1:2, 1])

    #make sure hidden categories are not displayed when output is a vector
    expect_equal(as.array(cube_ifany[1, ]), as.array(cube_ifany)[1, ])
    expect_equal(as.array(cube[1, ]), as.array(cube)[1, ])
})