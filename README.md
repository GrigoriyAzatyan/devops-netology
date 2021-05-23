# 5. Ознакомьтесь с графическим интерфейсом VirtualBox, посмотрите как выглядит виртуальная машина, которую создал для вас Vagrant, какие аппаратные ресурсы ей выделены. Какие ресурсы выделены по-умолчанию?
Память: 1024 МБ  
Процессоров: 2  
Ж.диск 40 ГБ /dev/sda + 10 МБ /dev/sdb

# 6. Ознакомьтесь с возможностями конфигурации VirtualBox через Vagrantfile: документация. Как добавить оперативной памяти или ресурсов процессора виртуальной машине?

	Vagrant.configure("2") do |config|  
 		config.vm.box = "bento/ubuntu-20.04"	  
	config.vm.provider "virtualbox" do |v|  
		v.memory = 2048	  
		v.cpus = 2  	
		end
	end

# 8. Ознакомиться с разделами man bash, почитать о настройках самого bash:

## Какой переменной можно задать длину журнала history, и на какой строчке manual это описывается?
*Не совсем однозначно понятна суть вопроса: есть длина файла журнала, и есть кол-во команд, которые можно запомнить в истории (по сути, длина истории).
Описано это здесь:*  
`man bash`  
`602g`

HISTFILESIZE  
              The maximum number of lines contained in the history file.  When this variable is assigned a value, the history file is truncated, if necessary, to contain no more than that number of lines by removing the oldest entries.  The history file is also truncated to this size after writing it when a shell exits.  If the value is 0, the history file is truncated to zero size.  Non-numeric values and numeric values less than  zero  inhibit truncation.  The shell sets the default value to the value of HISTSIZE after reading any startup files.  
     
HISTSIZE   
              The number of commands to remember in the command history (see HISTORY below).  If the value is 0, commands are not saved in the history list.  Numeric values less than zero result in every command being saved on the history list (there is no limit).  The shell sets the default value to 500 after reading any startup files.


## Что делает директива ignoreboth в bash?
В истории не будут сохраняться команды, начинающиеся с пробелов, а также уже внесенные ранее (ignorespace + ignoredups).  

# 9. В каких сценариях использования применимы скобки {} и на какой строчке man bash это описано?
* В перечислениях. Например: file{1,2,3}  - то же, что file1 file2 file3  
`man bash`  
`767g`  

* В массивах. Например: echo ${array[1]}  
`man bash`  
`707g`  

# 10. Основываясь на предыдущем вопросе, как создать однократным вызовом touch 100000 файлов? А получилось ли создать 300000?
*Спасибо, Google:*  
touch file{1..100000} 

touch file{1..300000}  
-bash: /usr/bin/touch: Слишком длинный список аргументов


# 11. В man bash поищите по /\[\[. Что делает конструкция [[ -d /tmp ]]
Проверяет, что /tmp - это каталог.

# 12. Основываясь на знаниях о просмотре текущих (например, PATH) и установке новых переменных; командах, которые мы рассматривали, добейтесь в выводе type -a bash в виртуальной машине наличия первым пунктом в списке:

	bash is /tmp/new_path_directory/bash
	bash is /usr/local/bin/bash
	bash is /bin/bash
(прочие строки могут отличаться содержимым и порядком)

-----
	sudo mkdir /tmp/new_path_directory
	sudo ln /usr/bin/bash /tmp/new_path_directory/bash
	echo export PATH="/tmp/new_path_directory:$PATH" >> ~/.bashrc
	source ~/.bashrc
	type -a bash

# 13. Чем отличается планирование команд с помощью batch и at?
Команда at используется для назначения одноразового задания на заданное время.  
Команда batch планирует задания и выполняет их в пакетной очереди, если позволяет уровень загрузки системы. По умолчанию задания выполняются, когда средняя загрузка системы ниже 1,5. Значение нагрузки можно указать при вызове демона atd . Если средняя загрузка системы выше указанной, задания будут ждать в очереди.

# 14. Завершите работу виртуальной машины чтобы не расходовать ресурсы компьютера и/или батарею ноутбука.
sudo poweroff  
или Ctrl+D // vagrant halt



