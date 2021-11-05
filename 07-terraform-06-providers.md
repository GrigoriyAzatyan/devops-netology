## Найдите, где перечислены все доступные resource и data_source, приложите ссылку на эти строки в коде на гитхабе.  
- Ресурсы: https://github.com/hashicorp/terraform-provider-aws/blob/aws_elasticache_replication_group_attributes_reader_endpoint/aws/provider.go#L398 
- DataSources: https://github.com/hashicorp/terraform-provider-aws/blob/aws_elasticache_replication_group_attributes_reader_endpoint/aws/provider.go#L167

## Для создания очереди сообщений SQS используется ресурс aws_sqs_queue у которого есть параметр name. С каким другим параметром конфликтует name? Приложите строчку кода, в которой это указано.
- https://github.com/hashicorp/terraform-provider-aws/blob/aws_elasticache_replication_group_attributes_reader_endpoint/aws/resource_aws_sqs_queue.go#L56  

## Какая максимальная длина имени?
- https://github.com/hashicorp/terraform-provider-aws/blob/aws_elasticache_replication_group_attributes_reader_endpoint/aws/validators.go#L1037

## Какому регулярному выражению должно подчиняться имя?  
- https://github.com/hashicorp/terraform-provider-aws/blob/aws_elasticache_replication_group_attributes_reader_endpoint/aws/validators.go#L1041
