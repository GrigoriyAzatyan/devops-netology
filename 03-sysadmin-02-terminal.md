## 1. Какого типа команда cd? Попробуйте объяснить, почему она именно такого типа; опишите ход своих мыслей, если считаете что она могла бы быть другого типа.
Встроенная команда оболочки bash:  
- man bash позволяет найти описание команды;
- на диске не удается найти исполняемый файл cd;
- man cd отсутствует.

## 2. Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l?  man grep поможет в ответе на этот вопрос. Ознакомьтесь с документом о других подобных некорректных вариантах использования pipe.
`grep <some_string> <some_file> -c   `  
(опция с команды grep позволяет вывести число найденных строк, не прибегая к другим командам.)

## 3. Какой процесс с PID 1 является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?   
`ps -p 1`  
 **systemd**

## 4. Как будет выглядеть команда, которая перенаправит вывод stderr ls на другую сессию терминала?  
`ls -l wrong_file 2> /dev/pts/1`

## 5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.  
`cat file1`  
333  
222  
444  
111  

`sort < file1 > output.txt`  
`cat output.txt`  
111  
222  
333  
444  

## 6. Получится ли вывести, находясь в графическом режиме, данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?  
Из PuTTY:
`echo Privet! > /dev/tty3`  

Ctrl-Alt-F3
Все успешно выводится. То же самое из графического терминала.  


## 7. Выполните команду bash 5>&1. К чему она приведет? Что будет, если вы выполните echo netology > /proc/$$/fd/5? Почему так происходит?    
Запустился новый экземпляр bash с новым PID на виртуальное устройство с файловым дескриптором 5, при этом весь вывод будет перенаправляться на стандартный поток вывода текущей оболочки.  
Выведется "netology" в текущем окне терминала, т.к. мы данной командой направили вывод на виртуальное устройство с  файловым дескриптором 5, но bash перенаправит этот вывод в окно текущего терминала.


## 8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty? Напоминаем: по умолчанию через pipe передается только stdout команды слева от | на stdin команды справа. Это можно сделать, поменяв стандартные потоки местами через промежуточный новый дескриптор, который вы научились создавать в предыдущем вопросе.  
`ls wrong_file 3>&2 2>&1 1>&3 | tee output.txt`

## 9. Что выведет команда cat /proc/$$/environ? Как еще можно получить аналогичный по содержанию вывод?  
Переменные окружения для процесса текущей оболочки.  
`ps e -p $$`

## 10. Используя man, опишите что доступно по адресам /proc/<PID>/cmdline, /proc/<PID>/exe.  
*/proc/[pid]/cmdline*     
*              This read-only file holds the complete command line for the process, unless the process is a zombie.  In the latter case, there is nothing in this file: that is,* *a read on this file will return 0 characters.  The command-line arguments appear in this file as a set of strings separated by null bytes ('\0'), with a further null byte* *after the last string.*  
**/proc/<PID>/cmdline - строка с параметрами запуска исполняемого файла процесса.**
  
 */proc/[pid]/exe*   
*              Under  Linux  2.2  and later, this file is a symbolic link containing the actual pathname of the executed command.  This symbolic link can be dereferenced normally; attempting to open it will open the executable.  You can even type /proc/[pid]/exe to run another copy of the same executable that is being run by process [pid]. If the pathname has been unlinked, the symbolic link will contain the string '(deleted)'  appended  to  the original pathname.  In a multithreaded process, the contents of this symbolic link are not available if the main thread has already terminated (typically by calling pthread_exit(3)).  
**/proc/[pid]/exe - символическая ссылка на путь к исполняемому файлу процесса.**             

## 11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью /proc/cpuinfo.    
`cat /proc/cpuinfo | grep sse`  
  flags  : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase avx2 invpcid rdseed clflushopt md_clear flush_l1d  
**Ответ: sse4_2**


## 12. При открытии нового окна терминала и vagrant ssh создается новая сессия и выделяется pty. Это можно подтвердить командой tty, которая упоминалась в лекции 3.2. Однако:
vagrant@netology1:~$ ssh localhost 'tty'
not a tty
Почитайте, почему так происходит, и как изменить поведение.   
**Ответ:**
man ssh позволяет найти такую информацию:   
          -t      Force pseudo-terminal allocation.  This can be used to execute arbitrary screen-based programs on a remote machine, which can be very useful, e.g. when implementing menu services.  Multiple -t options force tty allocation, even if ssh has no local tty.     

Очевидно, по умолчанию псевдотерминал не выделяется для удаленного запуска команды.
С ключом -t команда срабатывает:  
**ssh -t localhost 'tty'**    
grigorii_azatyan@localhost's password:  
/dev/pts/4  
 
## 13. Бывает, что есть необходимость переместить запущенный процесс из одной сессии в другую. Попробуйте сделать это, воспользовавшись reptyr. Например, так можно перенести в screen процесс, который вы запустили по ошибке в обычной SSH-сессии.
Попробовал, по этой инструкции: https://qastack.ru/superuser/623432/transfer-current-command-to-a-detachable-session-tmuxscreen  

## 14. sudo echo string > /root/new_file не даст выполнить перенаправление под обычным пользователем, так как перенаправлением занимается процесс shell'а, который запущен без sudo под вашим пользователем. Для решения данной проблемы можно использовать конструкцию echo string | sudo tee /root/new_file. Узнайте что делает команда tee и почему в отличие от sudo echo команда с sudo tee будет работать.
 
Ответ: tee записывает в файл стандартный поток вывода, а echo только выводит информацию на экран.
Соответственно, sudo echo не дает права записи в файл, т.к. данная команда и не записывает ничего в файл, а стандартный поток вывода из под обычного пользователя в папку рута доступа не имеет.
sudo tee как раз открывает файл на запись от имени рута, благодаря чему все завершается успешно.
Час ночи, пора спать.  
  
  
