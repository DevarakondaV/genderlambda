# Modify contentes as required.
#Write-Output "Adding lambda function to Compression"
Compress-Archive .\lambda_function.py -CompressionLevel Optimal -DestinationPath .\function.zip -Update

Write-Output "Pushing to aws"
C:\Users\vishnu\Envs\cloud\Scripts\activate.ps1
#Write-Output "Uploading to s3"
aws s3 cp packs.zip s3://gendermodel/
Write-Output "Uploading lambda function to s3"
aws s3 cp .\function.zip s3://gendermodel/
Write-Output "Updating Lambda Function"
aws lambda update-function-code --function-name genderclassify --s3-bucket gendermodel --s3-key function.zip
#deactivate
Write-Output "Upload complete"
