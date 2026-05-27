# src/workflows/train/workflows/training_workflow.py
from __future__ import annotations

from flytekit import workflow

from workflows.train.tasks.evaluate_and_register_task import evaluate_and_register_task
from workflows.train.tasks.train_model_task import train_model_task


@workflow
def train(
    train_num_threads: int = 1,
    tuning_sample_rows: int = 100_000,
    max_boost_rounds: int = 5_000,
    mlflow_experiment_name: str = "trip_eta_lgbm",
    max_eval_rows: int = 100_000,
    model_artifacts_s3_bucket: str = "",
    model_artifacts_s3_prefix: str = "",
    model_artifacts_s3_uri: str = "",
) -> str:
    # Build environment dict using Flyte-compatible approach
    # Use conditional expressions instead of if statements
    env_vars = {
        "MODEL_ARTIFACTS_S3_BUCKET": model_artifacts_s3_bucket,
        "MODEL_ARTIFACTS_S3_PREFIX": model_artifacts_s3_prefix,
        "MODEL_ARTIFACTS_S3_URI": model_artifacts_s3_uri,
    }
    
    training_result_json = train_model_task(
        train_num_threads=train_num_threads,
        tuning_sample_rows=tuning_sample_rows,
        max_boost_rounds=max_boost_rounds,
    ).with_overrides(environment=env_vars)

    return evaluate_and_register_task(
        training_result_json=training_result_json,
        mlflow_experiment_name=mlflow_experiment_name,
        max_eval_rows=max_eval_rows,
    )