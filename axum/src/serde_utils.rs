#![allow(dead_code)]
use serde::Serializer;

pub fn serialize_i64_as_bool<S: Serializer>(v: &i64, s: S) -> Result<S::Ok, S::Error> {
    s.serialize_bool(*v != 0)
}

pub fn serialize_opt_i64_as_bool<S: Serializer>(v: &Option<i64>, s: S) -> Result<S::Ok, S::Error> {
    match v {
        Some(n) => s.serialize_some(&(*n != 0)),
        None => s.serialize_none(),
    }
}
