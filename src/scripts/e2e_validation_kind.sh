make delete-temp-s3


ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

export S3_BUCKET=s3-temp-bucket-dataops-${ACCOUNT_ID}-xyz
export MLFLOW_S3_BUCKET=$S3_BUCKET
export PG_BACKUPS_S3_BUCKET=$S3_BUCKET
export MODEL_ARTIFACTS_S3_BUCKET=$S3_BUCKET
export AWS_REGION=${AWS_DEFAULT_REGION:-ap-south-1}

make temp-s3

make core                                  # create fresh kind Kubernetes cluster + default storage class

export K8S_CLUSTER=kind                    # target Kubernetes platform (kind)
export PG_BACKUPS_S3_BUCKET=$S3_BUCKET     # S3 bucket storing Postgres backups
export PG_CLUSTER_ID=cnpg-cluster-kind     # stable S3 namespace for this environment
export PG_SERVER_NAME=default-server-1     # stable backup lineage identifier
make pg-cluster                            # deploy fresh Postgres cluster (no restore, no initial backup)

make elt                                   # deploy Iceberg + Spark + Flyte and run ELT pipeline

make prune-elt                             # cleanup Spark operator / ELT-related resources

make train                                 # run Flyte training workflow (consumes Gold Iceberg tables)

aws s3 ls s3://$S3_BUCKET/model-artifacts/ --recursive
