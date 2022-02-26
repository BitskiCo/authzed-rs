#[cfg(feature = "v0")]
pub mod v0 {
    tonic::include_proto!("authzed.api.v0");
}

#[cfg(feature = "v1")]
pub mod v1 {
    tonic::include_proto!("authzed.api.v1");
}

#[cfg(feature = "v1alpha1")]
pub mod v1alpha1 {
    tonic::include_proto!("authzed.api.v1alpha1");
}
