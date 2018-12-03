# aws-lambda-r-runtime

This package makes it easy to run AWS Lambda Functions written in R.

## Example
To run the example, we need to create a IAM role executing our lambda.
This role should have the following properties:
- Trusted entity – Lambda.
- Permissions – AWSLambdaBasicExecutionRole.
- Role name – example-lambda-r-role.

Furthermore you need a current version of the AWS CLI.

Then create a lambda function which uses the R runtime layer:
```bash
cd example/
chmod 755 script.r
zip function.zip script.r
aws lambda create-function --function-name r-example \
    --zip-file fileb://function.zip --handler script.handler \
    --runtime provided --timeout 60 \
    --layers arn:aws:lambda:eu-central-1:131329294410:layer:r-runtime:10 \
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
    --layers arn:aws:lambda:eu-central-1:131329294410:layer:r-runtime:10 \
        arn:aws:lambda:eu-central-1:131329294410:layer:r-recommended:1 \
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

## Layers

Layers are only accessible in the AWS region they were published.
We provide the following layers:

### r-runtime

R 3.5.1, httr, jsonlite, aws.s3

- eu-central-1: arn:aws:lambda:eu-central-1:131329294410:layer:r-runtime:10
- us-east-1: arn:aws:lambda:us-east-1:131329294410:layer:r-runtime:1

### r-recommended

The recommended packages that ship with R 3.5.1:
boot, class, cluster, codetools, foreign, KernSmooth, lattice, MASS, Matrix, mgcv, nlme, nnet, rpart, spatial, survival

- eu-central-1: arn:aws:lambda:eu-central-1:131329294410:layer:r-recommended:1
- us-east-1: arn:aws:lambda:us-east-1:131329294410:layer:r-recommended:1


## Documentation

The lambda handler is used to determine both the file name of the R script and the function to call.
The handler must be separated by `.`, e.g., `script.handler`.

The lambda payload is unwrapped as named arguments to the R function to call, e.g., `{"x":1}` is unwrapped to `handler(x=1)`.

The lambda function returns whatever is returned by the R function as a JSON object with `result` as a root element.

In order to install additional R packages, you can create a lambda layer containing the libraries, just as in the second example.
The file structure must be `R/library/MY_LIBRARY`.
See `build_recommended_layer.sh` for an example.
If you need system libraries, place them in `R/lib/`.

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

You can customize the R version by setting the `VERSION` variable.
The script produces a zip containing a functional R installation in `/opt/R/`.
Place this archive in the repository and run the `build_runtime.sh` script.
This creates a lambda layer named `r-runtime` in your AWS account.
You can use it as shown in the example.
