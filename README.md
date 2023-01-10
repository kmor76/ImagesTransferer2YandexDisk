# ImagesTransferer2YandexDisk 
1. Inspect and fill main.tfvars
	1. Yandex Cloud token and other
		1. https://cloud.yandex.com/en/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider
	2. Yandex Disk API Token
		1. https://yandex.ru/dev/disk/api/concepts/quickstart.html#quickstart__oauth
2. Add images to ./transferer/images.txt (Last line should be EOL only)
3. For Windows ensure ./transferer/fileToYaDisk.txt has only LF instead CRFL (git config --global core.autocrlf false)
4. terraform init
3. terraform validate
4. terraform apply -var-file=./main.tfvars
5. terraform destroy -var-file=./main.tfvars