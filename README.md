# aws-lambda-r-runtime

[![Build Status](https://travis-ci.com/bakdata/aws-lambda-r-runtime.svg?branch=master)](https://travis-ci.com/bakdata/aws-lambda-r-runtime)

This project makes it easy to run AWS Lambda Functions written in R.

## Example
To run the example, we need to create a IAM role executing our lambda.
This role should have the following properties:
- Trusted entity – Lambda.
- Permissions – AWSLambdaBasicExecutionRole.

Furthermore you need a current version of the AWS CLI.

Then create a lambda function which uses the R runtime layer:
```bash
cd example/
chmod 755 script.R
zip function.zip script.R
# current region
region=$(aws configure get region)
# latest runtime layer ARN for R 3.6.0 in most regions
# for an accurate list, please have a look at the deploy section of the travis ci build log
# https://travis-ci.com/bakdata/aws-lambda-r-runtime
runtime_layer=arn:aws:lambda:$region:131329294410:layer:r-runtime-3_6_0:13
aws lambda create-function --function-name r-example \
    --zip-file fileb://function.zip --handler script.handler \
    --runtime provided --timeout 60 \
    --layers ${runtime_layer} \
    --role <role-arn>
```

The function simply increments 'x' by 1.
Invoke the function:
```bash
aws lambda invoke --function-name r-example \
    --payload '{"x":1}' response.txt
cat response.txt
```

The expected result should look similar to this:
```json
2
```

### Using packages

We also provide a layer which ships with some recommended R packages, such as `Matrix`.
This example lambda shows how to use them:
```bash
cd example/
chmod 755 matrix.R
zip function.zip matrix.R
# current region
region=$(aws configure get region)
# latest runtime layer ARN for R 3.6.0 in most regions
# for an accurate list, please have a look at the deploy section of the travis ci build log
# https://travis-ci.com/bakdata/aws-lambda-r-runtime
runtime_layer=arn:aws:lambda:$region:131329294410:layer:r-runtime-3_6_0:13
# latest recommended layer ARN for R 3.6.0 in most regions
# for an accurate list, please have a look at the deploy section of the travis ci build log
# https://travis-ci.com/bakdata/aws-lambda-r-runtime
recommended_layer=arn:aws:lambda:$region:131329294410:layer:r-recommended-3_6_0:13
aws lambda create-function --function-name r-matrix-example \
    --zip-file fileb://function.zip --handler matrix.handler \
    --runtime provided --timeout 60 --memory-size 3008 \
    --layers ${runtime_layer} ${recommended_layer} \
    --role <role-arn>
```

The function returns the second column of some static matrix.
Invoke the function:
```bash
aws lambda invoke --function-name r-matrix-example response.txt
cat response.txt
```

The expected result should look similar to this:
```json
[4,5,6]
```

## Provided layers

Layers are only accessible in the AWS region they were published.
We provide the following layers:

### r-runtime

R,
[httr](https://cran.r-project.org/package=httr),
[jsonlite](https://cran.r-project.org/package=jsonlite),
[aws.s3](https://cran.r-project.org/package=aws.s3),
[logging](https://cran.r-project.org/package=logging)

Available AWS regions:
- ap-northeast-1
- ap-northeast-2
- ap-south-1
- ap-southeast-1
- ap-southeast-2
- ca-central-1
- eu-central-1
- eu-north-1
- eu-west-1
- eu-west-2
- eu-west-3
- sa-east-1
- us-east-1
- us-east-2
- us-west-1
- us-west-2

Available R versions:
- 3_5_1
- 3_5_3
- 3_6_0

Latest ARN can be retrieved from the [Travis CI build log](https://travis-ci.com/bakdata/aws-lambda-r-runtime). In general, it looks this:

`arn:aws:lambda:$region:131329294410:layer:r-runtime-$r_version:$layer_version`

Automated command for retrieving the ARN does not work currently:
```bash
aws lambda list-layer-versions --max-items 1 --no-paginate  \
    --layer-name arn:aws:lambda:${region}:131329294410:layer:r-runtime-${r_version} \
    --query 'LayerVersions[0].LayerVersionArn' --output text
```

### r-recommended

The recommended packages that ship with R:
boot,
class,
cluster,
codetools,
foreign,
KernSmooth,
lattice,
MASS,
Matrix,
mgcv,
nlme,
nnet,
rpart,
spatial,
survival

Available AWS regions:
- ap-northeast-1
- ap-northeast-2
- ap-south-1
- ap-southeast-1
- ap-southeast-2
- ca-central-1
- eu-central-1
- eu-north-1
- eu-west-1
- eu-west-2
- eu-west-3
- sa-east-1
- us-east-1
- us-east-2
- us-west-1
- us-west-2

Available R versions:
- 3_5_1
- 3_5_3
- 3_6_0

Latest ARN can be retrieved from the [Travis CI build log](https://travis-ci.com/bakdata/aws-lambda-r-runtime). In general, it looks this:

`arn:aws:lambda:$region:131329294410:layer:r-recommended-$r_version:$layer_version`

Automated command for retrieving the ARN does not work currently:
```bash
aws lambda list-layer-versions --max-items 1 --no-paginate  \
    --layer-name arn:aws:lambda:${region}:131329294410:layer:r-recommended-${r_version} \
    --query 'LayerVersions[0].LayerVersionArn' --output text
```

### r-awspack

The [aws.s3](https://cran.r-project.org/package=aws.s3) package.
It used to contain the [awspack](https://cran.r-project.org/package=awspack) package but unfortunately this package has been retired.
You can still find it in old versions of the layer that have been published before 2020.

Available AWS regions:
- ap-northeast-1
- ap-northeast-2
- ap-south-1
- ap-southeast-1
- ap-southeast-2
- ca-central-1
- eu-central-1
- eu-north-1
- eu-west-1
- eu-west-2
- eu-west-3
- sa-east-1
- us-east-1
- us-east-2
- us-west-1
- us-west-2

Available R versions:
- 3_5_1
- 3_5_3
- 3_6_0

Latest ARN can be retrieved from the [Travis CI build log](https://travis-ci.com/bakdata/aws-lambda-r-runtime). In general, it looks this:

`arn:aws:lambda:$region:131329294410:layer:r-awspack-$r_version:$layer_version`

Automated command for retrieving the ARN does not work currently:
```bash
aws lambda list-layer-versions --max-items 1 --no-paginate  \
    --layer-name arn:aws:lambda:${region}:131329294410:layer:r-awspack-${r_version} \
    --query 'LayerVersions[0].LayerVersionArn' --output text
```

## Documentation

The lambda handler is used to determine both the file name of the R script and the function to call.
The handler must be separated by `.`, e.g., `script.handler`.

The lambda payload is unwrapped as named arguments to the R function to call, e.g., `{"x":1}` is unwrapped to `handler(x=1)`.

The lambda function returns whatever is returned by the R function as a JSON object.

### Building custom layers

In order to install additional R packages, you can create a lambda layer containing the libraries, just as in the second example.
You must use the the compiled package files.
The easiest way is to install the package with `install.packages()` and copy the resulting folder in `$R_LIBS`.
Using only the package sources does not suffice.
The file structure must be `R/library/<my-library>`.
If your package requires system libraries, place them in `R/lib/`.

You can use Docker for building your layer.
You need to run `./docker_build.sh` first.
Then you can install your packages inside the container and copy the files to your machine.
See `awspack/` for an example.
The `build.sh` script is used to run the docker container and copy sources to your machine.
The `entrypoint.sh` script is used for installing packages inside the container.

### Debugging

In order to make the runtime log debugging messages, you can set the environment variable `LOGLEVEL` to `DEBUG`.

## Limitations

AWS Lambda is limited to running with 3GB RAM and must finish within 15 minutes.
It is therefore not feasible to execute long running R scripts with this runtime.
Furthermore, only the `/tmp/` directory is writeable on AWS Lambda.
This must be considered when writing to the local disk. 


## Building

To build the layer yourself, you need to first build R from source.
We provide a Docker image which uses the great [docker-lambda](https://github.com/lambci/docker-lambda) project.
Just run `./build.sh <version>` and everything should be build properly.

If you plan to publish the runtime, you need to have a recent version of aws cli (>=1.16).
Now run the `<layer>/deploy.sh` script.
This creates a lambda layer named `r-<layer>-<version>` in your AWS account.
You can use it as shown in the example.

### Compiling on EC2

In case the Docker image does not properly represent the lambda environment,
we also provide a script which launches an EC2 instance, compiles R, and uploads the zipped distribution to S3.
You need to specify the R version, e.g., `3.6.0`, as well as the S3 bucket to upload the distribution to.
Finally, you need to create an EC2 instance profile which is capable of uploading to the S3 bucket.
See the [AWS documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html#create-iam-role) for details.
With everything prepared, you can run the script:
```bash
./remote_compile_and_deploy.sh <version> <bucket-name> <instance-profile>
```
The script will also take care of terminating the launched EC2 instance.

To manually build R from source, follow these steps:

Start an EC2 instance which uses the [Lambda AMI](https://console.aws.amazon.com/ec2/v2/home#Images:visibility=public-images;search=amzn-ami-hvm-2017.03.1.20170812-x86_64-gp2):
```bash
aws ec2 run-instances --image-id ami-657bd20a --count 1 --instance-type t2.medium --key-name <my-key-pair>
```
Now run the `compile.sh` script in `r/`.
You must pass the R version as a parameter to the script, e.g., `3.6.0`.
The script produces a zip containing a functional R installation in `/opt/R/`.
The relevant files can be found in `r/build/bin/`.
Use this R distribution for building the layers.

### Testing

After building all layers, you can test it locally with SAM CLI and Docker.
Install it via `pipenv install --dev`.
Then run `python3 -m unittest`.
This will spawn a local lambda server via Docker and invokes the lambdas defined in `template.yaml`.
