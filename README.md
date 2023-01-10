# ImagesTransferer2YandexDisk
1. Inspect and fill main.tfvars
2. Add images to ./transferer/images.txt (Last line should be EOL only)
3. terraform validate
4. terraform apply -var-file=./main.tfvars
5. terraform destroy -var-file=./main.tfvars