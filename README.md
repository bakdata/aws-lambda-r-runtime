# aws-lambda-r-runtime

[![Build Status](https://travis-ci.com/bakdata/aws-lambda-r-runtime.svg?branch=master)](https://travis-ci.com/bakdata/aws-lambda-r-runtime)

This package makes it easy to run AWS Lambda Functions written in R.

## Example
To run the example, we need to create a IAM role executing our lambda.
This role should have the following properties:
- Trusted entity – Lambda.
- Permissions – AWSLambdaBasicExecutionRole.

Furthermore you need a current version of the AWS CLI.

Then create a lambda function which uses the R runtime layer:
```bash
cd example/
chmod 755 script.r
zip function.zip script.r
aws lambda create-function --function-name r-example \
    --zip-file fileb://function.zip --handler script.handler \
    --runtime provided --timeout 60 \
    --layers arn:aws:lambda:eu-central-1:131329294410:layer:r-runtime-3_5_1:1 \
    --role <role-arn> --region eu-central-1
```

The function simply increments 'x' by 1.
Invoke the function:
```bash
aws lambda invoke --function-name r-example \
    --payload '{"x":1}' --region eu-central-1 response.txt
cat response.txt
```

The expected result should look similar to this:
```json
{"result":2}
```

### Using packages

We also provide a layer which ships with some recommended R packages, such as `Matrix`.
This example lambda shows how to use them:
```bash
cd example/
chmod 755 matrix.r
zip function.zip matrix.r
aws lambda create-function --function-name r-matrix-example \
    --zip-file fileb://function.zip --handler matrix.handler \
    --runtime provided --timeout 60 --memory-size 3008 \
    --layers arn:aws:lambda:eu-central-1:131329294410:layer:r-runtime-3_5_1:1 \
        arn:aws:lambda:eu-central-1:131329294410:layer:r-recommended-3_5_1:1 \
    --role <role-arn> --region eu-central-1
```

The function returns the second column of some static matrix.
Invoke the function:
```bash
aws lambda invoke --function-name r-matrix-example \
    --region eu-central-1 response.txt
cat response.txt
```

The expected result should look similar to this:
```json
{"result":[4,5,6]}
```

## Provided layers

Layers are only accessible in the AWS region they were published.
We provide the following layers:

### r-runtime

R, httr, jsonlite, aws.s3

Available AWS regions:
- ap-northeast-1
- ap-northeast-2
- ap-south-1
- ap-southeast-1
- ap-southeast-2
- ca-central-1
- eu-central-1
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

ARN: `arn:aws:lambda:${region}:131329294410:layer:r-runtime-${version}:1`

### r-recommended

The recommended packages that ship with R:
boot, class, cluster, codetools, foreign, KernSmooth, lattice, MASS, Matrix, mgcv, nlme, nnet, rpart, spatial, survival

Available AWS regions:
- ap-northeast-1
- ap-northeast-2
- ap-south-1
- ap-southeast-1
- ap-southeast-2
- ca-central-1
- eu-central-1
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

ARN: `arn:aws:lambda:${region}:131329294410:layer:r-recommended-${version}:1`

## Documentation

The lambda handler is used to determine both the file name of the R script and the function to call.
The handler must be separated by `.`, e.g., `script.handler`.

The lambda payload is unwrapped as named arguments to the R function to call, e.g., `{"x":1}` is unwrapped to `handler(x=1)`.

The lambda function returns whatever is returned by the R function as a JSON object with `result` as a root element.

In order to install additional R packages, you can create a lambda layer containing the libraries, just as in the second example.
The file structure must be `R/library/<MY_LIBRARY>`.
See `build_recommended.sh` for an example.
If your package requires system libraries, place them in `R/lib/`.

## Limitations

AWS Lambda is limited to running with 3GB RAM and must finish within 15 minutes.
It is therefore not feasible to execute long running R scripts with this runtime.
Furthermore, only the `/tmp/` directory is writeable on AWS Lambda.
This must be considered when writing to the local disk. 


## Building

To build the layer yourself, you need to first build R from source.
Start an EC2 instance which uses the [Lambda AMI](https://console.aws.amazon.com/ec2/v2/home#Images:visibility=public-images;search=amzn-ami-hvm-2017.03.1.20170812-x86_64-gp2) and run the `build_r.sh` script:
```bash
aws ec2 run-instances --image-id ami-657bd20a --count 1 --instance-type t2.micro --key-name <MyKeyPair>
```

You must pass the R version as a parameter to the script, e.g., `3.5.1`.
The script produces a zip containing a functional R installation in `/opt/R/`.
Place this archive in the repository and run the `build_runtime_and_publish.sh` script.
This creates a lambda layer named `r-runtime` in your AWS account.
You can use it as shown in the example.
