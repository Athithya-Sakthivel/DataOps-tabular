from __future__ import annotations

import os

from flytekit import LaunchPlan

from workflows.train.workflows.training_workflow import train

DEFAULT_TRAIN_NUM_THREADS = 1
DEFAULT_TUNING_SAMPLE_ROWS = 100_000
DEFAULT_MAX_BOOST_ROUNDS = 5_000
DEFAULT_MLFLOW_EXPERIMENT_NAME = "trip_eta_lgbm"
DEFAULT_MAX_EVAL_ROWS = 100_000

TRAIN_WORKFLOW_LP_NAME = "train_default"

# Read MODEL_* env vars at registration time so your shell values become LaunchPlan defaults
DEFAULT_MODEL_ARTIFACTS_S3_BUCKET = os.environ.get("MODEL_ARTIFACTS_S3_BUCKET", "")
DEFAULT_MODEL_ARTIFACTS_S3_PREFIX = os.environ.get("MODEL_ARTIFACTS_S3_PREFIX", "")
DEFAULT_MODEL_ARTIFACTS_S3_URI = os.environ.get("MODEL_ARTIFACTS_S3_URI", "")

TRAIN_WORKFLOW_LP = LaunchPlan.get_or_create(
    workflow=train,
    name=TRAIN_WORKFLOW_LP_NAME,
    default_inputs={
        "train_num_threads": DEFAULT_TRAIN_NUM_THREADS,
        "tuning_sample_rows": DEFAULT_TUNING_SAMPLE_ROWS,
        "max_boost_rounds": DEFAULT_MAX_BOOST_ROUNDS,
        "mlflow_experiment_name": DEFAULT_MLFLOW_EXPERIMENT_NAME,
        "max_eval_rows": DEFAULT_MAX_EVAL_ROWS,
        "model_artifacts_s3_bucket": DEFAULT_MODEL_ARTIFACTS_S3_BUCKET,
        "model_artifacts_s3_prefix": DEFAULT_MODEL_ARTIFACTS_S3_PREFIX,
        "model_artifacts_s3_uri": DEFAULT_MODEL_ARTIFACTS_S3_URI,
    },
)

__all__ = [
    "DEFAULT_MAX_BOOST_ROUNDS",
    "DEFAULT_MAX_EVAL_ROWS",
    "DEFAULT_MLFLOW_EXPERIMENT_NAME",
    "DEFAULT_TRAIN_NUM_THREADS",
    "DEFAULT_TUNING_SAMPLE_ROWS",
    "TRAIN_WORKFLOW_LP",
    "TRAIN_WORKFLOW_LP_NAME",
]
