#include "RcppArmadillo.h"
#include <cmath>
#include "partitionfuns.h"

// [[Rcpp::depends(RcppArmadillo)]]

void update_cluster_labels(
    arma::uvec& current_cluster_assignment,
    const arma::mat& dist_mat,
    const arma::vec& cluster_probs,
    const arma::vec& alpha_old,
    const int& n_items,
    const std::string& metric,
    const Rcpp::Nullable<arma::vec> cardinalities = R_NilValue,
    const Rcpp::Nullable<arma::vec> logz_estimate = R_NilValue
){
  int n_assessors = current_cluster_assignment.n_elem;
  int n_clusters = dist_mat.n_cols;

  arma::mat assignment_prob(n_assessors, n_clusters);
  for(int cluster_index = 0; cluster_index < n_clusters; ++cluster_index){
    // Compute the logarithm of the unnormalized probability
    assignment_prob.col(cluster_index) = std::log(cluster_probs(cluster_index)) -
      alpha_old(cluster_index) / n_items * dist_mat.col(cluster_index) -
      get_partition_function(n_items, alpha_old(cluster_index), cardinalities, logz_estimate, metric);
  }

  for(int assessor_index = 0; assessor_index < n_assessors; ++assessor_index){
    // Exponentiate to get unnormalized prob relative to max
    arma::rowvec probs = arma::exp(assignment_prob.row(assessor_index) -
      arma::max(assignment_prob.row(assessor_index)));

    // Normalize with 1-norm
    probs = arma::normalise(probs, 1);

    assignment_prob.row(assessor_index) = probs;
    current_cluster_assignment(assessor_index) = sample_int(assignment_prob.row(assessor_index));
  }
}

arma::vec update_cluster_probs(
    const arma::uvec& current_cluster_assignment,
    const int& n_clusters,
    const int& psi
){

  arma::vec cluster_probs(n_clusters);

  for(int cluster_index = 0; cluster_index < n_clusters; ++cluster_index){
    // Find the parameter for this cluster and provide it to the gamma distribution
    cluster_probs(cluster_index) = arma::randg<double>(arma::distr_param(arma::sum(current_cluster_assignment == cluster_index) + psi, 1.0));
  }
  // Finally, normalize cluster_probs with 1-norm.
  // result now comes from Dirichlet(tau_k(0), ..., tau_k(n_clusters))
  return arma::normalise(cluster_probs, 1);

}


arma::vec update_wcd(const arma::uvec& current_cluster_assignment,
                     const arma::mat& dist_mat){
  int n_clusters = dist_mat.n_cols;
  arma::vec wcd(n_clusters);

  arma::uvec inds = arma::regspace<arma::uvec>(0, n_clusters - 1);
  for(int i = 0; i < n_clusters; ++i){
    arma::mat dist_vec = dist_mat.submat(arma::find(current_cluster_assignment == i), inds.subvec(i, i));
    wcd(i) = arma::sum(arma::conv_to<arma::vec>::from(dist_vec));
  }

  return(wcd);
}
