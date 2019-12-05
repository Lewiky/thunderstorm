# Thunderstorm

## Golden Nonce Discovery in The Cloud 

Coursework for COMSM0010 Cloud Computing

## Directory Structure

`/tf` - Terraform Scripts describing all components of the cloud infrastructure used by this system

`/cli` - Python clients for interacting with the system

`/lambda` - Sources for the three lambda functions used in the system

`/container` - Sources for the docker container used to do POW exercises

## How To Run

1. Build the docker container and push to ECR via [usual methods](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)

2. Zip up lambda functions into deployment zips and push these to their appropriate S3 locations

3. Deploy Infrastruture: Run `terraform apply` in this directory to provision infrastructure from within the `tf` dir, may need to update things like the S3 bucket name/ container repository ID to make it use correct sources

4. Run `python3 cli/nonce_cli.py` with following options: 
    - `--difficulty INT` - The difficulty to search at
    - `--time INT` the required time to search for nonces (timeout after this amount of time)
    - `--confidence FLOAT` the confidence interval of finding an answer in the time
    - `--block STRING` the data block to prepend to the nonce before searching
    - `--workers INT [OPTIONAL]` If defined, overrides the logic to specify time and confidence and instead explicitly sets number of workers(but timeout still applies)
