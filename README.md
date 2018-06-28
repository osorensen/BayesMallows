
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BayesMallows

This is the internal repository for development of the BayesMallows
package. All feedback and suggestions are very welcome. Feel free to
create a [Pull Request](https://github.uio.no/oyss/BayesMallows/pulls)
or an [Issue](https://github.uio.no/oyss/BayesMallows/issues).

Please also check out the [Suggested
Roadmap](https://github.uio.no/oyss/BayesMallows/wiki/Roadmap).

To install the current development version of the package, you should
clone or download this repository, and then open `BayesMallows.Rproj` in
RStudio and click **Build** and then **Install and Restart** on the top
meny.

## Function Overview

This table describes the high level functions informally. It is aimed at
giving an overview of the package. Check the documentation for arguments
and return
values.

| Function Name            | Description                                                                                                                                                                                           |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `get_partition_function` | Returns the partition function for the Mallows model, given the necessary parameters, including distance measure. This function should have reasonable defaults for how the computation is performed. |
| `get_rank_distance`      | Returns the distance between two rank vectors, in the metric specified.                                                                                                                               |
| `compute_posterior`      | Runs the MCMC algorithm and computes the posterior distribution. The return values must include some convergence diagnostics. I suggest giving the return object S3 class `BayesMallows`.             |
| `plot.BayesMallows`      | S3 method for plotting the posterior distribution. Note that the user only needs to call `plot`.                                                                                                      |
| `summary.BayesMallows`   | S3 method for summarizing the posterior distribution.                                                                                                                                                 |

## Coding Style

I follow [The tidyverse style
guide](http://style.tidyverse.org/index.html). In particular, all
`variable_names` with lowercase letters separated by underscore,
function names are verbs, and object names are nouns.
